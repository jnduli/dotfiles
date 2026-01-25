local M = {}

DONE_CHECKLIST = "- [X]"
OPEN_CHECKLIST = "- [ ]"

local CHECKLIST_STATUS = {
  OPEN = 1,
  DONE = 2,
  UNKNOWN = 3,
}

local Checklist = {}
Checklist.__index = Checklist

function Checklist.new(status, time, content)
  local self = setmetatable({}, Checklist)
  self.status = status
  self.time = time
  self.content = content
  return self
end

function Checklist:is_done()
  return self.status == CHECKLIST_STATUS.DONE
end

function Checklist:is_open()
  return self.status == CHECKLIST_STATUS.OPEN
end

function Checklist.get_time(text)
  local default_time = "24:00"
  -- Matches: "10:30", "10.30pm", "10:30 AM"
  local h_str, m_str, ampm = text:lower():match("(%d%d?)[%s%p]+(%d%d)%s*([ap]?m?)")

  if not h_str then
    return default_time
  end

  local h = tonumber(h_str)
  local m = tonumber(m_str)

  local h24 = h

  if ampm then
    if ampm == "pm" and h < 12 then
      h24 = h + 12
    elseif ampm == "am" and h == 12 then
      h24 = 0
    end
  end

  local res = string.format("%02d:%02d", h24, m)
  if res == nil then
    return default_time
  end
  return res
end

function Checklist.from_str(raw_string)
  local status = string.sub(raw_string, 1, string.len(DONE_CHECKLIST))
  local status_obj = CHECKLIST_STATUS.UNKNOWN

  if status == DONE_CHECKLIST then
    status_obj = CHECKLIST_STATUS.DONE
  elseif status == OPEN_CHECKLIST then
    status_obj = CHECKLIST_STATUS.OPEN
  end

  local time_convert = Checklist.get_time(raw_string)
  return Checklist.new(status_obj, time_convert, raw_string)
end

-- Checklist object utils
--

M.pace_score = function(start, end_time, total_tasks, tasks_done)
  -- TODO: figure out how to handle work hours here for better scaling
  local total_available_hours = (end_time.hour - start.hour) + ((end_time.min - start.min) / 60)
  if vim.g.missing_hours ~= nil then
    total_available_hours = total_available_hours - vim.g.missing_hours
  end

  local expected_pace_per_hour = total_tasks / total_available_hours
  local cur_time = os.date("*t")
  local hours_passed = (cur_time.hour - start.hour) + ((cur_time.min - start.min) / 60)
  local expected_tasks_done = hours_passed * expected_pace_per_hour
  local performance = tasks_done / expected_tasks_done -- can be greater than 100% which is what I want
  return { score = performance, expected_done = expected_tasks_done }
end

M.STARS_HIGHLIGHT_GROUP = "TaskAnimStars"
M.STARS_NAMESPACE_ID = vim.api.nvim_create_namespace("StarsVirtualTextNamespace")

-- Animation utils

M.easing_in_out_quad = function(t)
  return t < 0.5 and 2 * t * t or 1 - math.pow(-2 * t + 2, 2) / 2
end

M.animate = function(frame_rate_ms, duration_ms, on_update, on_complete)
  local timer = vim.uv.new_timer()
  if timer == nil then
    return
  end
  local start_time = vim.uv.now()
  timer:start(0, frame_rate_ms, function()
    local elapsed_time = vim.uv.now() - start_time
    local raw_progress = math.min(1, elapsed_time / duration_ms)
    local eased_progress = M.easing_in_out_quad(raw_progress)
    on_update(eased_progress)

    if raw_progress >= 1 then
      timer:stop()
      timer:close()
      if on_complete then
        on_complete()
      end
    end
  end)
  return timer
end

M.animate_character_horizontal = function(row, col, characters, on_complete)
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, false, {
    relative = "editor",
    width = 2,
    height = 1,
    row = row,
    col = col,
    style = "minimal",
  })
  local single_action = function(ratio)
    local idx = math.floor((ratio * #characters) + 0.5)
    local g = characters[idx + 1]
    vim.schedule(function()
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, { g })
      vim.hl.range(buf, M.STARS_NAMESPACE_ID, M.STARS_HIGHLIGHT_GROUP, { 0, 0 }, { 10, 10 })
    end)
  end

  local clean_up = function()
    vim.schedule(function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end)
    if on_complete then
      on_complete()
    end
  end

  local duration_ms = 250
  local refresh_ms = 40 -- 24 fps
  M.animate(refresh_ms, duration_ms, single_action, clean_up)
end

M.popup_stars = function(row, col, on_complete)
  local stars = { " .", "✨", "☆", "★", "★", "★" }
  M.animate_character_horizontal(row, col, stars, on_complete)
end

M.Checklist = Checklist

return M
