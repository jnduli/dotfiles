local M = {}

RESULTS = {}

LOGGER = require("plenary.log").new({
    plugin = "ai_helper",
    level = "debug",
})

local get_content = function(first_pos, last_pos)
    -- first_pos and last_pos are arrays, similar to output of getpos
    local content_table = vim.fn.getregion(first_pos, last_pos)
    local selected_string = ""
    for _, val in pairs(content_table) do
        selected_string = selected_string .. "\n" .. val
    end

    return selected_string
end

local append_content = function(first_pos, last_pos, new_content)
    vim.fn.setpos(".", { first_pos[1], last_pos[2], 1, 0 })
    vim.cmd("normal o")
    vim.cmd("normal o")
    vim.api.nvim_put(new_content, "", true, true)
end

local replace_content = function(first_pos, last_pos, new_content)
    local end_col = last_pos[3] - 1
    if last_pos[3] >= 2147483647 then
        local line_no = last_pos[2] - 1
        local last_line = vim.api.nvim_buf_get_lines(0, line_no, line_no + 1, false)[1]
        end_col = string.len(last_line)
    end

    vim.api.nvim_buf_set_text(first_pos[1], first_pos[2] - 1, first_pos[3] - 1, last_pos[2] - 1, end_col, {})
    vim.api.nvim_put(new_content, "", true, true)
end


local new_window = function(first_pos, last_pos)
    local width = 100
    local height = 10

    local buffer = vim.api.nvim_create_buf(false, false)
    local popup = require("plenary.popup")

    local borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }

    local current_win_id, _ = popup.create(buffer, {
        title = "Gemini Call: r-replace, a-append, q-quit",
        line = math.floor(((vim.o.lines - height) / 2) - 1),
        col = math.floor((vim.o.columns - width) / 2),
        minwidth = width,
        minheight = height,
        borderchars = borderchars,
    })
    vim.api.nvim_buf_set_option(buffer, "buftype", "nofile")
    vim.api.nvim_buf_set_option(buffer, "bufhidden", "delete")
    vim.api.nvim_buf_set_keymap(buffer, "n", "q", "", {
        callback = function()
            vim.api.nvim_win_close(current_win_id, true)
        end,
        silent = true
    })
    vim.api.nvim_buf_set_keymap(buffer, "n", "r", "", {
        callback = function()
            vim.api.nvim_win_close(current_win_id, true)
            replace_content(first_pos, last_pos, RESULTS["result"])
        end,
        silent = true
    })

    vim.api.nvim_buf_set_keymap(buffer, "n", "a", "", {
        callback = function()
            vim.api.nvim_win_close(current_win_id, true)
            append_content(first_pos, last_pos, RESULTS["result"])
        end,
        silent = true
    })
    return buffer
end

local gemini_api_call = function(content)
    local prompt = "taking the role of a senior software engineer, rewrite the content in a short and clear way: " ..
    content
    LOGGER.debug("AI prompt: ", prompt)

    local parts_json = { parts = { { text = prompt } } }
    local query_json = { contents = { parts_json } }
    local query_string = vim.json.encode(query_json)
    local google_api_key = os.getenv("GOOGLE_API_KEY")
    if google_api_key == nil then
        error("GOOGLE_API_KEY env variable not set")
    end
    local curl_command = {
        "curl",
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=" .. google_api_key,
        "-H", "Content-Type: application/json",
        "-X", "POST",
        "-d",
        query_string
    }
    local result = nil
    vim.system(curl_command, { text = true }, function(obj)
        LOGGER.debug("AI result", obj.stdout)
        result = obj.stdout
    end):wait()

    if result == nil then
        error("Failed to get result from gemini api")
    end

    local decoded_result = vim.json.decode(result)
    return decoded_result["candidates"][1]["content"]["parts"][1]["text"]
end

function M.reset()
    package.loaded["ai_helper"] = nil
    require("ai_helper")
end

function M.gemini_call(content, first_pos, last_pos)
    -- FIXME: replace this to use proper gemini responses, for now I'll use this to test
    local buffer = new_window(first_pos, last_pos)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, true, { "Calling gemini api" })
    local gem_result = gemini_api_call(content)
    local gem_table = {}
    for line in string.gmatch(gem_result, '[^\n]+') do
        table.insert(gem_table, line)
    end

    RESULTS["result"] = gem_table
    vim.api.nvim_buf_set_lines(buffer, 0, -1, true, gem_table)
end

function M.setup()
    vim.api.nvim_create_user_command("AiReset", M.reset, {})
    vim.api.nvim_create_user_command("Ai", function()
            local first_pos = vim.fn.getpos("'<")
            local last_pos = vim.fn.getpos("'>")
            local visual_selection = get_content(first_pos, last_pos)
            M.gemini_call(visual_selection, first_pos, last_pos)
        end,
        { range = true })
end

M.setup()

return M
