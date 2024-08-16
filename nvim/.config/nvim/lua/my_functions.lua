local M = {}

local goto_random_line = function ()
  local line_no = vim.api.nvim_buf_line_count(0)
  local random = math.random(0, line_no)
  vim.cmd(string.format(":call cursor(%d, %d)", random, 1))
end

function M.say_line()
  local cmd = 'espeak -- "' .. vim.api.nvim_get_current_line() .. '"'
  vim.fn.system(cmd)
end

function M.github_path_link()
  -- Returns a path to github.com for the current line
  -- e.g. https://github.com/jnduli/dotfiles/blob/57ebd0145c85580a171285a4440b8d16e74c380c/i3/i3status_config#L14
  local originUrl = vim.fn.system('git config --get remote.origin.url')
  local mainBranch = vim.fn.system('git symbolic-ref --short refs/remotes/origin/HEAD')
  local mainHash = vim.fn.trim(vim.fn.system('git rev-parse ' .. mainBranch))
  local gitPathToFile = vim.fn.trim(vim.fn.system('git ls-files --full-name ' .. vim.fn.expand("%")))


  if gitPathToFile == nil or gitPathToFile == '' then
    error("File " .. vim.fn.expand("%") .. " is not a tracked git file")
  end

  local github_relative_path = vim.fn.split(originUrl, 'github.com:\\?')[2]
  local relative_path = vim.fn.split(github_relative_path, '\\.')[1]
  -- local relativeGithub = vim.fn.trim(vim.fn.split(vim.fn.split(originUrl, 'github.com:\\?')[2], '\.')[1])
  local path = 'https://github.com/' ..
      relative_path .. '/blob/' .. mainHash .. '/' .. gitPathToFile .. '#L' .. vim.fn.line(".")
  vim.cmd("let @+ = '" .. path .. "'")
end


local reload_work_content = function(buffer)
  local env = { WORK_LOG = "/home/rookie/vimwiki/scripts/genenetwork_work_tracker/logs.toml"}
  local cmd_obj = vim.system({"work-log", "--report", "--output-format=json"}, { text = true , env = env}):wait()
  if string.find(cmd_obj.stdout, "No tasks found") then
    local contents = {"No tasks", }
    vim.api.nvim_buf_set_lines(buffer, 0, -1, true, contents)
    return
  end

  local parse_json = vim.json.decode(cmd_obj.stdout)
  local contents = {}
  for idx, val in pairs(parse_json) do
    contents[idx] = string.format("%s: %s", val["description"], val["status"])
  end
  vim.api.nvim_buf_set_lines(buffer, 0, -1, true, contents)
  return contents
end

local update_work_log = function(win_id, action_flag, buffer_json)
  local linenr = vim.api.nvim_win_get_cursor(win_id)[1]
  local task = buffer_json[linenr]
  local task_uuid = task["uuid"]
  local env = { WORK_LOG = "/home/rookie/vimwiki/scripts/genenetwork_work_tracker/logs.toml"}
  vim.system({"work-log", "--task", task_uuid, action_flag}, { text = true , env = env}):wait()
  vim.print(string.format("Updated task: %s", task_uuid))
end


local new_window = function()
  -- Nice to haves: hight light full line if I'm on the line
  --https://www.statox.fr/posts/2021/03/breaking_habits_floating_window/
  local width = 100
  local height = 10

  local buffer = vim.api.nvim_create_buf(false, false)
  local popup = require("plenary.popup")

  local borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }

  local current_win_id, _ = popup.create(buffer, {
      title = "Work Log: a - add, r - start, p - pause, d - complete task, q - close ",
      line = math.floor(((vim.o.lines - height) / 2) - 1),
      col = math.floor((vim.o.columns - width) / 2),
      minwidth = width,
      minheight = height,
      borderchars = borderchars,
  })
  local buffer_json = reload_work_content(buffer)
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
      update_work_log(current_win_id, "--start", buffer_json)
      buffer_json = reload_work_content(buffer)
    end
  })
  vim.api.nvim_buf_set_keymap(buffer, "n", "p", "", {
    callback = function()
      update_work_log(current_win_id, "--pause", buffer_json)
      buffer_json = reload_work_content(buffer)
    end
  })
  vim.api.nvim_buf_set_keymap(buffer, "n", "d", "", {
    callback = function()
      update_work_log(current_win_id, "--complete", buffer_json)
      buffer_json = reload_work_content(buffer)
    end
  })
  vim.api.nvim_buf_set_keymap(buffer, "n", "a", "", {
    callback = function()
        vim.ui.input({ prompt = 'Add Task: ' }, function(input)
          local env = { WORK_LOG = "/home/rookie/vimwiki/scripts/genenetwork_work_tracker/logs.toml"}
          local cmd_obj = vim.system({"work-log", "--add", input}, { text = true , env = env}):wait()
          vim.print(cmd_obj.stdout)
          buffer_json = reload_work_content(buffer)
        end)
    end
  })
end


M.setup = function()
  vim.api.nvim_create_user_command("RandomLine", goto_random_line, {})
  vim.api.nvim_create_user_command("GitLink", M.github_path_link, {})
  vim.api.nvim_create_user_command("Say", M.say_line, {})
  vim.api.nvim_create_user_command("LPop", new_window, {})
  vim.api.nvim_create_user_command("MReload", function ()
    package.loaded["my_functions"] = nil
    local my_fns = require("my_functions")
    my_fns.setup()
  end

    , {})
end

return M

