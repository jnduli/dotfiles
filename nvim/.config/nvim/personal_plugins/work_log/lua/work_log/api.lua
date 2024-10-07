--
-- Improvements to add today
-- When someone clicks enter on a task, open the detailed view
-- Attempt to show summary for total times taked, and show status took
-- Show colors depending on status
--
local M = {}

local run_work_log_cmd = function(work_log_args)
  local work_log_env = os.getenv("WORK_LOG")
  table.insert(work_log_args, 1, "work-log")
  if work_log_env == nil then
    error("WORK_LOG env variable not set")
  end
  local env = { WORK_LOG = work_log_env }
  local cmd_obj = vim.system(work_log_args, { text = true, env = env }):wait()
  return cmd_obj
end

local get_work_content = function()
  local cmd_obj = run_work_log_cmd({ "--report", "--output-format=json" })
  if string.find(cmd_obj.stdout, "No tasks found") then
    return nil
  end

  local parse_json = vim.json.decode(cmd_obj.stdout)
  return parse_json
end


local reload_work_content = function(buffer, contents_json)
  if contents_json == nil then
    vim.api.nvim_buf_set_lines(buffer, 0, -1, true, { "No tasks", })
    return
  end

  local contents = {}
  for idx, val in pairs(contents_json) do
    contents[idx] = string.format("%s: %s", val["description"], val["status"])
  end
  vim.api.nvim_buf_set_lines(buffer, 0, -1, true, contents)
end

local update_work_log = function(win_id, action_flag, buffer_json)
  local linenr = vim.api.nvim_win_get_cursor(win_id)[1]
  local task = buffer_json[linenr]
  local task_uuid = task["uuid"]
  run_work_log_cmd({ "--task", task_uuid, action_flag })
  vim.print(string.format("Updated task: %s", task_uuid))
end

local load_task_content = function(buffer, task)
  local contents = {}
  contents[1] = string.format("UUID: %s", task["uuid"])
  contents[2] = string.format("description: %s", task["description"])
  contents[3] = string.format("status: %s, minutes: %d", task["status"], task["minutes"])
  contents[4] = "Notes:"

  for _, val in pairs(task["notes"]) do
    table.insert(contents, string.format("  %s", val))
  end

  table.insert(contents, "Press q to go back to log listing")
  vim.api.nvim_buf_set_lines(buffer, 0, -1, true, contents)
end


function M.new_window()
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
  local buffer_json = get_work_content()
  reload_work_content(buffer, buffer_json)
  local window_state = "TASKS"
  vim.api.nvim_buf_set_option(buffer, "buftype", "nofile")
  vim.api.nvim_buf_set_option(buffer, "bufhidden", "delete")
  vim.api.nvim_buf_set_keymap(buffer, "n", "q", "", {
    callback = function()
      if window_state == "TASKS" then
        vim.api.nvim_win_close(current_win_id, true)
      else
        buffer_json = get_work_content()
        reload_work_content(buffer, buffer_json)
        window_state = "TASKS"
      end
    end,
    silent = true
  })
  vim.api.nvim_buf_set_keymap(buffer, "n", "r", "", {
    callback = function()
      update_work_log(current_win_id, "--start", buffer_json)
      buffer_json = get_work_content()
      reload_work_content(buffer, buffer_json)
    end
  })
  vim.api.nvim_buf_set_keymap(buffer, "n", "p", "", {
    callback = function()
      update_work_log(current_win_id, "--pause", buffer_json)
      buffer_json = get_work_content()
      reload_work_content(buffer, buffer_json)
    end
  })
  vim.api.nvim_buf_set_keymap(buffer, "n", "d", "", {
    callback = function()
      update_work_log(current_win_id, "--complete", buffer_json)
      buffer_json = get_work_content()
      reload_work_content(buffer, buffer_json)
    end
  })
  vim.api.nvim_buf_set_keymap(buffer, "n", "a", "", {
    callback = function()
      vim.ui.input({ prompt = 'Add Task/Note: ' }, function(input)
        local cmd_obj = nil
        if window_state == "TASKS" then
          cmd_obj = run_work_log_cmd({ "--add", input })
          buffer_json = get_work_content()
          reload_work_content(buffer, buffer_json)
        else
          local task = buffer_json[window_state]
          cmd_obj = run_work_log_cmd({ "--task", task["uuid"], "--note", input })
          buffer_json = get_work_content()
          task = buffer_json[window_state]
          load_task_content(buffer, task)
        end

        vim.print(cmd_obj.stdout)
      end)
    end
  })
  vim.api.nvim_buf_set_keymap(buffer, "n", "<Enter>", "", {
    callback = function()
      --- FIX_ME, bad design
      ---
      local linenr = vim.api.nvim_win_get_cursor(current_win_id)[1]
      window_state = linenr
      local task = buffer_json[linenr]
      load_task_content(buffer, task)
    end
  })
end

return M
