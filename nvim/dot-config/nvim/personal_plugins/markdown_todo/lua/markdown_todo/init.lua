local utils = require("markdown_todo.utils")
local M = {}

local log_level = "info" -- change to debug for more logs
local log = require("plenary.log").new({
  -- logs stored in echo stdpath("log")/custom_markdown.log
  plugin = "custom_markdown",
  level = log_level,
})

local default_config = {
  start_time = { hour = 5, min = 0 },
  end_time = { hour = 21, min = 0 },
}

M.config = {}

local DELAYED_TASK_NAMESPACE_ID = vim.api.nvim_create_namespace("DelayedTaskNamespace")
local DELAYED_HIGHLIGHT_GROUP = "DelayedTaskHighlight"
vim.api.nvim_set_hl(0, DELAYED_HIGHLIGHT_GROUP, { bg = "#711D1D", fg = "#FFFFFF" }) -- Red background, white text

vim.api.nvim_set_hl(0, utils.STARS_HIGHLIGHT_GROUP, { fg = "#ffc000", bold = true, default = true })

M.move_up_checklist_item = function(lnum)
  if not lnum then
    lnum = vim.fn.getcurpos()[2] - 1
  end
  local up_lnum = lnum - 1
  while up_lnum > 0 do
    local current_line = vim.api.nvim_buf_get_lines(0, up_lnum, up_lnum + 1, false)[1]
    local checklist = utils.Checklist.from_str(current_line)
    if checklist == nil or checklist.content == "" then
      break
    end
    if checklist:is_done() then
      break
    end
    up_lnum = up_lnum - 1
  end

  if lnum == up_lnum + 1 then -- same line
    return
  end

  local line = vim.api.nvim_buf_get_lines(0, lnum, lnum + 1, false)[1]
  log.debug("Moving " .. line .. " from: " .. lnum .. " to: " .. up_lnum)
  vim.api.nvim_buf_set_lines(0, lnum, lnum + 1, false, {})
  vim.api.nvim_buf_set_lines(0, up_lnum + 1, up_lnum + 1, false, { line })
end

M.highlight_delayed_tasks = function()
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_clear_namespace(buf, DELAYED_TASK_NAMESPACE_ID, 0, -1)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local cur_time = os.date("*t")
  local compare_time = string.format("%02d:%02d", cur_time.hour, cur_time.min)
  for idx, line in ipairs(lines) do
    local checklist_obj = utils.Checklist.from_str(line)
    if checklist_obj and checklist_obj:is_open() then
      if checklist_obj.time < compare_time then
        -- Add highlight to the entire line (idx-1 because nvim_buf_add_highlight is 0-indexed)
        vim.api.nvim_buf_add_highlight(buf, DELAYED_TASK_NAMESPACE_ID, DELAYED_HIGHLIGHT_GROUP, idx - 1, 0, -1)
      end
    end
  end
end

-- markdown cycle through todo list items
M.toggle_markdown_checklist = function()
  local current_cursor = vim.fn.getcurpos()
  local current_line = vim.api.nvim_buf_get_lines(0, current_cursor[2] - 1, current_cursor[2], false)[1]
  local next_checklist_table = { [OPEN_CHECKLIST] = DONE_CHECKLIST, [DONE_CHECKLIST] = OPEN_CHECKLIST }
  local dash_col, _ = string.find(current_line, "[-*]")
  if dash_col == nil then
    return
  end
  local current_check = vim.api.nvim_buf_get_text(
    0,
    current_cursor[2] - 1,
    dash_col - 1,
    current_cursor[2] - 1,
    dash_col + string.len(DONE_CHECKLIST) - 1,
    {}
  )[1]
  local next_content = next_checklist_table[current_check]
  if next_content == nil then
    return
  end

  local next_actions = function()
    vim.schedule(function()
      vim.api.nvim_buf_set_text(
        0,
        current_cursor[2] - 1,
        dash_col - 1,
        current_cursor[2] - 1,
        dash_col + string.len(DONE_CHECKLIST) - 1,
        { next_content }
      )
      if dash_col - 1 == 0 then
        M.move_up_checklist_item(current_cursor[2] - 1)
      end
      vim.fn.setpos(".", current_cursor)
    end)
  end
  if next_content == DONE_CHECKLIST then
    local cur_win_cursor = vim.api.nvim_win_get_cursor(0) -- 0 refers to the current window
    local screen_pos_info = vim.fn.screenpos(0, cur_win_cursor[1], dash_col)
    if screen_pos_info.row == 0 or screen_pos_info.col == 0 then
      return
    end

    utils.popup_stars(screen_pos_info.row - 1, screen_pos_info.col + 2, next_actions)
  else
    next_actions()
  end
end

local STATS_NAMESPACE_ID = vim.api.nvim_create_namespace("StatsVirtualTextNamespace")
local GLOBAL_TOP_LINE_INDEX = nil

local STATUS_COLORS = {
  "#FF0000",
  "#FF3300",
  "#FF6600",
  "#FF9900",
  "#FFCC00",
  "#FFFF00",
  "#CCFF00",
  "#99FF00",
  "#66FF00",
  "#33FF00",
  "#00FF00",
}
M.highlight_name = function(idx)
  return string.format("StatsHighlight_%d", idx)
end

M.create_stats_highlight_groups = function()
  for idx, color in ipairs(STATUS_COLORS) do
    vim.api.nvim_set_hl(0, M.highlight_name(idx), { fg = "black", bg = color, bold = true })
  end
end

M.get_stats_highlight = function(ratio)
  -- local length = #STATUS_COLORS
  local length = 10
  if ratio == nil then
    ratio = 0
  end
  if ratio > 1 then
    ratio = 1
  end
  local index = vim.fn.round(ratio * length) + 1
  return M.highlight_name(index)
end

M.reorder = function()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local start = nil
  local ch_end = nil
  local orders = {}
  local seen_content = {}
  for idx, line in ipairs(lines) do
    local checklist_obj = utils.Checklist.from_str(line)
    if checklist_obj and checklist_obj:is_open() then
      if start == nil then
        start = idx
      end
      if ch_end == nil then
        ch_end = idx
      end
      if not seen_content[line] then
        table.insert(orders, { checklist_obj.time, line })
        seen_content[line] = true
      end
      start = math.min(start, idx)
      ch_end = math.max(ch_end, idx)
    end
  end
  table.sort(orders, function(a, b)
    return a[1] < b[1]
  end)
  local new_list = {}
  for _, v in ipairs(orders) do
    table.insert(new_list, v[2])
  end
  if start == nil or ch_end == nil then
    return
  end
  log.debug("Changing new list")
  vim.api.nvim_buf_set_lines(0, start - 1, ch_end, false, new_list) -- indexing is 0-based
end

M.stats = function()
  local buf = vim.api.nvim_get_current_buf()

  local winline = vim.fn.winline() -- get current line relative to the top of the window
  local current_cursor = vim.fn.getcurpos()
  local current_line = current_cursor[2] -- get current line relative to the whole file
  local line_with_stats = math.max(current_line - winline, 0)
  if GLOBAL_TOP_LINE_INDEX == line_with_stats and not vim.bo.modified then
    return
  end

  vim.api.nvim_buf_clear_namespace(buf, STATS_NAMESPACE_ID, 0, -1)

  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local total = 0
  local done = 0
  for _, line in ipairs(lines) do
    local checklist_obj = utils.Checklist.from_str(line)
    if checklist_obj and checklist_obj:is_done() then
      done = done + 1
      total = total + 1
    elseif checklist_obj and checklist_obj:is_open() then
      total = total + 1
    end
  end
  if total == 0 then
    return
  end
  local performance = utils.pace_score(M.config.start_time, M.config.end_time, total, done)
  local stats_msg = string.format("Pace: %d/%d, %.1f%%", done, performance.expected_done, performance.score * 100)
  local stats_highlight = M.get_stats_highlight(performance.score)

  GLOBAL_TOP_LINE_INDEX = line_with_stats
  vim.api.nvim_buf_set_extmark(buf, STATS_NAMESPACE_ID, line_with_stats, 0, {
    virt_text = { { stats_msg, stats_highlight } },
    virt_text_pos = "eol_right_align",
  })
end

-- TODO: things here
M.calculate_and_print = function(args)
  local res, err = math.add(args.fargs[1], args.fargs[2])

  if err then
    vim.notify("Error: " .. err, vim.log.levels.ERROR)
  else
    print("Result: " .. res)
  end
end

function M.setup(user_opts)
  user_opts = user_opts or {}

  -- Basic check for the top-level table
  vim.validate({
    schedule = { user_opts.schedule, "table", true },
  })

  -- Check nested values if they exist
  if user_opts.schedule then
    if user_opts.schedule.start_time then
      vim.validate({
        hour = { user_opts.schedule.start_time.hour, "number" },
        min = { user_opts.schedule.start_time.min, "number" },
      })
    end
    if user_opts.schedule.end_time then
      vim.validate({
        hour = { user_opts.schedule.end_time.hour, "number" },
        min = { user_opts.schedule.end_time.min, "number" },
      })
    end
  end

  M.config = vim.tbl_deep_extend("force", default_config, user_opts or {})
end

return M
