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
  done_task_position = "top",
  readjust_interval_minutes = 30,
}

M.config = {}

local DELAYED_TASK_NAMESPACE_ID = vim.api.nvim_create_namespace("DelayedTaskNamespace")
local DELAYED_HIGHLIGHT_GROUP = "DelayedTaskHighlight"

local COLORS = {
  dark = {
    delayed_bg      = "#711D1D",
    delayed_fg      = "#FFFFFF",
    stars           = "#ffc000",
    status_gradient = {
      "#FF0000", "#FF3300", "#FF6600", "#FF9900", "#FFCC00", "#FFFF00",
      "#CCFF00", "#99FF00", "#66FF00", "#33FF00", "#00FF00",
    },
  },
  light = {
    delayed_bg      = "#FFCCCC",
    delayed_fg      = "#7A0000",
    stars           = "#B8860B",
    status_gradient = {
      "#FFB3B3", "#FFBBA0", "#FFC880", "#FFD966", "#FFEE66", "#FFFF99",
      "#EEFF88", "#CCFF99", "#B3FF99", "#99FF88", "#80FF80",
    },
  },
}

local function theme()
  return COLORS[vim.o.background] or COLORS.dark
end

local function get_section_boundaries(lnum)
  local total_lines = vim.api.nvim_buf_line_count(0)

  local function is_checklist(line)
    return line and line:match("^%s*[-*]%s*")
  end

  local section_start = lnum
  for i = lnum - 1, 0, -1 do
    local line = vim.api.nvim_buf_get_lines(0, i, i + 1, false)[1]
    if not is_checklist(line) then
      break
    end
    section_start = i
  end

  local section_end = lnum
  for i = lnum + 1, total_lines - 1 do
    local line = vim.api.nvim_buf_get_lines(0, i, i + 1, false)[1]
    if not is_checklist(line) then
      break
    end
    section_end = i
  end

  return section_start, section_end
end

M.get_section_boundaries = get_section_boundaries

M.move_up_checklist_item = function(lnum)
  if not lnum then
    lnum = vim.fn.getcurpos()[2] - 1
  end
  local section_start, _ = get_section_boundaries(lnum)
  local up_lnum = section_start

  if lnum == up_lnum then -- same line
    return
  end

  local line = vim.api.nvim_buf_get_lines(0, lnum, lnum + 1, false)[1]
  log.debug("Moving " .. line .. " from: " .. lnum .. " to: " .. up_lnum)
  vim.api.nvim_buf_set_lines(0, lnum, lnum + 1, false, {})
  vim.api.nvim_buf_set_lines(0, up_lnum, up_lnum, false, { line })
end

M.move_down_checklist_item = function(lnum)
  if not lnum then
    lnum = vim.fn.getcurpos()[2] - 1
  end
  local total_lines = vim.api.nvim_buf_line_count(0)
  local _, section_end = get_section_boundaries(lnum)
  local down_lnum = section_end + 1

  if lnum == down_lnum - 1 then -- same line
    return
  end

  local line = vim.api.nvim_buf_get_lines(0, lnum, lnum + 1, false)[1]
  log.debug("Moving " .. line .. " from: " .. lnum .. " to: " .. down_lnum)
  vim.api.nvim_buf_set_lines(0, lnum, lnum + 1, false, {})
  vim.api.nvim_buf_set_lines(0, down_lnum - 1, down_lnum - 1, false, { line })
end

local function get_file_date()
  local filename = vim.fn.expand("%:t:r")
  local year, month, day = filename:match("(%d%d%d%d)-(%d%d)-(%d%d)")
  if year then
    return { year = tonumber(year), month = tonumber(month), day = tonumber(day) }
  end
  return nil
end

local function file_date_relation(file_date)
  local today = os.date("*t")
  local today_ts = os.time({ year = today.year, month = today.month, day = today.day, hour = 0, min = 0, sec = 0 })
  local file_ts = os.time({ year = file_date.year, month = file_date.month, day = file_date.day, hour = 0, min = 0, sec = 0 })
  local diff = math.floor((file_ts - today_ts) / 86400)
  if diff == 0 then
    return "today"
  elseif diff > 0 then
    return "future"
  else
    return "past"
  end
end

M.highlight_delayed_tasks = function()
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_clear_namespace(buf, DELAYED_TASK_NAMESPACE_ID, 0, -1)

  local file_date = get_file_date()
  local relation = file_date and file_date_relation(file_date) or "today"

  if relation == "future" then
    return
  end

  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

  if relation == "past" then
    for idx, line in ipairs(lines) do
      local checklist_obj = utils.Checklist.from_str(line)
      if checklist_obj and checklist_obj:is_open() then
        vim.api.nvim_buf_add_highlight(buf, DELAYED_TASK_NAMESPACE_ID, DELAYED_HIGHLIGHT_GROUP, idx - 1, 0, -1)
      end
    end
  else
    local cur_time = os.date("*t")
    local compare_minutes = cur_time.hour * 60 + cur_time.min
    for idx, line in ipairs(lines) do
      local checklist_obj = utils.Checklist.from_str(line)
      if checklist_obj and checklist_obj:is_open() then
        if checklist_obj:day_minutes() < compare_minutes then
          vim.api.nvim_buf_add_highlight(buf, DELAYED_TASK_NAMESPACE_ID, DELAYED_HIGHLIGHT_GROUP, idx - 1, 0, -1)
        end
      end
    end
  end
end

M.readjust_timers = function()
  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local cur_time = os.date("*t")
  local current_minutes = cur_time.hour * 60 + cur_time.min

  local overdue_tasks = {}
  for idx, line in ipairs(lines) do
    local checklist_obj = utils.Checklist.from_str(line)
    if checklist_obj and checklist_obj:is_open() then
      local task_minutes = checklist_obj:day_minutes()

      if task_minutes < current_minutes then
        table.insert(overdue_tasks, {
          line_index = idx - 1,
          original_time = task_minutes,
          line = line,
        })
      end
    end
  end

  table.sort(overdue_tasks, function(a, b)
    return a.original_time < b.original_time
  end)

  for i, task in ipairs(overdue_tasks) do
    local interval = M.config.readjust_interval_minutes or 30
    local new_minutes = current_minutes + (interval * (i - 1))
    local new_hour = math.floor(new_minutes / 60)
    local new_min = new_minutes % 60
    local new_time = string.format("%02d:%02d", new_hour, new_min)

    local new_line = task.line:gsub("%d%d?[:.]%d%d%s*[ap]?m?", new_time)
    if new_line == task.line then
      new_line = task.line:gsub("(- %[%])", "%1 " .. new_time, 1)
    end

    vim.api.nvim_buf_set_lines(buf, task.line_index, task.line_index + 1, false, { new_line })
    log.debug("Readjusted task from line " .. (task.line_index + 1) .. " to " .. new_time)
  end

  if #overdue_tasks > 0 then
    vim.notify("Readjusted " .. #overdue_tasks .. " overdue task(s)", vim.log.levels.INFO)
  else
    vim.notify("No overdue tasks to readjust", vim.log.levels.INFO)
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
      if dash_col - 1 == 0 and M.config.done_task_position ~= "none" then
        if M.config.done_task_position == "top" then
          M.move_up_checklist_item(current_cursor[2] - 1)
        elseif M.config.done_task_position == "bottom" then
          M.move_down_checklist_item(current_cursor[2] - 1)
        end
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

M.highlight_name = function(idx)
  return string.format("StatsHighlight_%d", idx)
end

M.create_stats_highlight_groups = function()
  for idx, color in ipairs(theme().status_gradient) do
    vim.api.nvim_set_hl(0, M.highlight_name(idx), { fg = "black", bg = color, bold = true })
  end
end

local function setup_highlights()
  local t = theme()
  vim.api.nvim_set_hl(0, DELAYED_HIGHLIGHT_GROUP, { bg = t.delayed_bg, fg = t.delayed_fg })
  vim.api.nvim_set_hl(0, utils.STARS_HIGHLIGHT_GROUP, { fg = t.stars, bold = true })
  M.create_stats_highlight_groups()
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
        table.insert(orders, { checklist_obj:day_minutes(), line })
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
    done_task_position = { user_opts.done_task_position, "string", true },
    readjust_interval_minutes = { user_opts.readjust_interval_minutes, "number", true },
  })

  if user_opts.done_task_position then
    local valid = { top = true, bottom = true, none = true }
    if not valid[user_opts.done_task_position] then
      vim.notify(
        "Invalid done_task_position: " .. user_opts.done_task_position .. " (must be 'top', 'bottom', or 'none')",
        vim.log.levels.ERROR
      )
      user_opts.done_task_position = nil
    end
  end

  if user_opts.readjust_interval_minutes and user_opts.readjust_interval_minutes <= 0 then
    vim.notify("Invalid readjust_interval_minutes: " .. user_opts.readjust_interval_minutes .. " (must be > 0)", vim.log.levels.ERROR)
    user_opts.readjust_interval_minutes = nil
  end

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

  setup_highlights()
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("MarkdownTodoHighlights", { clear = true }),
    callback = setup_highlights,
  })
end

return M
