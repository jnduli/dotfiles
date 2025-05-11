local gemini = require("ai_helper.gemini")

local LOGGER = require("ai_helper.log").logger

local M = {}

RESULTS = {}

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

    local visual_selection = get_content(first_pos, last_pos)
    local buffer = vim.api.nvim_create_buf(false, false)
    local popup = require("plenary.popup")

    local borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }

    local mode = "call_ai" -- can also be prompt
    local prompt = gemini.prompts["senior_eng"]

    local current_win_id, _ = popup.create(buffer, {
        title = "Gemini Call: r-replace content/replace prompt, a-append, c-change prompt, q-quit",
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
            if mode == "select_prompt" then
                M.gemini_call(buffer, visual_selection, prompt)
                mode = "call_ai"
                return
            end
            vim.api.nvim_win_close(current_win_id, true)
        end,
        silent = true
    })
    vim.api.nvim_buf_set_keymap(buffer, "n", "r", "", {
        callback = function()
            if mode == "select_prompt" then
                local line = vim.fn.line(".")
                local prompt_key = vim.api.nvim_buf_get_lines(buffer, line-1, line, false)
                prompt = gemini.prompts[prompt_key[1]]
                M.gemini_call(buffer, visual_selection, prompt)
                mode = "call_ai"
                return
            end
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
    vim.api.nvim_buf_set_keymap(buffer, "n", "c", "", {
        callback = function()
            local con = {}
            for k, _ in pairs(gemini.prompts) do
                table.insert(con, k)
            end
            vim.api.nvim_buf_set_lines(buffer, 0, -1, true, con)
            mode = "select_prompt"
        end,
        silent = true
    })
    return buffer
end

function M.reset()
    package.loaded["ai_helper"] = nil
    package.loaded["ai_helper.gemini"] = nil
    require("ai_helper")
    require("ai_helper.gemini")
end

function M.gemini_call(buffer, content, prompt)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, true, { "Calling gemini api" })
    if prompt == nil then
        prompt = gemini.prompts["senior_eng"]
    end
    local gem_result = gemini.api_call(content, prompt)
    if gem_result == nil then
        vim.api.nvim_buf_set_lines(buffer, 0, -1, true, { "Errors encountered calling gemini api" })
        return
    end
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
            local buffer = new_window(first_pos, last_pos)
            M.gemini_call(buffer, visual_selection)
        end,
        { range = true })
end

M.setup()

return M
