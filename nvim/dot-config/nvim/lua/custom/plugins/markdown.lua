vim.treesitter.language.register("markdown", "vimwiki")

local log_level = "info" -- change to debug for more logs
local log = require("plenary.log").new({
  -- logs stored in echo stdpath("log")/custom_markdown.log
  plugin = "custom_markdown",
  level = log_level,
})

DONE_CHECKLIST = "- [X]"
OPEN_CHECKLIST = "- [ ]"
local STARS_HIGHLIGHT_GROUP = "TaskAnimStars"
local STARS_NAMESPACE_ID = vim.api.nvim_create_namespace("StarsVirtualTextNamespace")
print(STARS_NAMESPACE_ID)

vim.api.nvim_set_hl(0, STARS_HIGHLIGHT_GROUP, { fg = "#ffc000", bold = true, default = true })

local CHECKLIST_STATUS = {
  OPEN = 1,
  DONE = 2,
  UNKNOWN = 3,
}

local easing_in_out_quad = function(t)
  return t < 0.5 and 2 * t * t or 1 - math.pow(-2 * t + 2, 2) / 2
end

local animate = function(frame_rate_ms, duration_ms, on_update, on_complete)
  local timer = vim.uv.new_timer()
  if timer == nil then
    return
  end
  local start_time = vim.uv.now()
  timer:start(0, frame_rate_ms, function()
    local elapsed_time = vim.uv.now() - start_time
    local raw_progress = math.min(1, elapsed_time / duration_ms)
    local eased_progress = easing_in_out_quad(raw_progress)
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

-- Original function (for context and testing)
function convert_time_to_sortable_format(text)
  local h_str, m_str = text:match("(%d%d?)%p(%d%d)")
  local ampm = text:match("%s*([ap]m)%s*")

  if not h_str then
    return nil -- No time found
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

  return string.format("%02d:%02d", h24, m)
end

local animate_character_horizontal = function(row, col, characters, on_complete)
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
      vim.hl.range(buf, STARS_NAMESPACE_ID, STARS_HIGHLIGHT_GROUP, { 0, 0 }, { 10, 10 })
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
  animate(refresh_ms, duration_ms, single_action, clean_up)
end

local function popup_stars(row, col, on_complete)
  local stars = { " .", "✨", "☆", "★", "★", "★" }
  animate_character_horizontal(row, col, stars, on_complete)
end

local function str_to_checklist(raw_string)
  local status = string.sub(raw_string, 1, string.len(DONE_CHECKLIST))
  local status_obj = CHECKLIST_STATUS.UNKNOWN
  if status == DONE_CHECKLIST then
    status_obj = CHECKLIST_STATUS.DONE
  elseif status == OPEN_CHECKLIST then
    status_obj = CHECKLIST_STATUS.OPEN
  else
    return nil
  end
  return { status = status_obj, content = raw_string }
end

local function move_up_checklist_item(lnum)
  if not lnum then
    lnum = vim.fn.getcurpos()[2] - 1
  end
  local up_lnum = lnum - 1
  while up_lnum > 0 do
    local current_line = vim.api.nvim_buf_get_lines(0, up_lnum, up_lnum + 1, false)[1]
    local checklist = str_to_checklist(current_line)
    if checklist == nil then
      break
    end
    if checklist.status == CHECKLIST_STATUS.DONE then
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

-- markdown cycle through todo list items
local function toggle_markdown_checklist()
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
        move_up_checklist_item(current_cursor[2] - 1)
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

    popup_stars(cur_win_cursor[1] - 1, screen_pos_info.col + 2, next_actions)
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
local function highlight_name(idx)
  return string.format("StatsHighlight_%d", idx)
end

local function create_stats_highlight_groups()
  for idx, color in ipairs(STATUS_COLORS) do
    vim.api.nvim_set_hl(0, highlight_name(idx), { fg = "black", bg = color, bold = true })
  end
end

local function get_stats_highlight(ratio)
  -- local length = #STATUS_COLORS
  local length = 10
  if ratio == nil then
    ratio = 0
  end
  local index = vim.fn.round(ratio * length) + 1
  return highlight_name(index)
end

local function reorder()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local start = nil
  local ch_end = nil
  local orders = {}
  for idx, line in ipairs(lines) do
    local checklist_obj = str_to_checklist(line)
    if checklist_obj and checklist_obj.status == CHECKLIST_STATUS.OPEN then
      if start == nil then
        start = idx
      end
      if ch_end == nil then
        ch_end = idx
      end
      local time_convert = convert_time_to_sortable_format(line)
      if time_convert == nil then
        time_convert = "24:00"
      end
      table.insert(orders, { time_convert, line })
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

  vim.api.nvim_buf_set_lines(0, start - 1, ch_end, false, new_list) -- indexing is 0-based
end

local function stats()
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
    local checklist_obj = str_to_checklist(line)
    if checklist_obj and checklist_obj.status == CHECKLIST_STATUS.DONE then
      done = done + 1
      total = total + 1
    elseif checklist_obj and checklist_obj.status == CHECKLIST_STATUS.OPEN then
      total = total + 1
    end
  end
  if total == 0 then
    return
  end
  local ratio = done / total
  local percentage = ratio * 100
  local stats_msg = string.format("%d/%d, %.1f%%", done, total, percentage)
  local stats_highlight = get_stats_highlight(ratio)

  GLOBAL_TOP_LINE_INDEX = line_with_stats
  vim.api.nvim_buf_set_extmark(buf, STATS_NAMESPACE_ID, line_with_stats, 0, {
    virt_text = { { stats_msg, stats_highlight } },
    virt_text_pos = "eol_right_align",
  })
end

local markdown_group = vim.api.nvim_create_augroup("markdown_group", { clear = true })
vim.api.nvim_create_autocmd("Filetype", {
  pattern = { "markdown", "vimwiki", "*.md" },
  callback = function()
    create_stats_highlight_groups()
    vim.bo.textwidth = 120
    vim.keymap.set("n", "<C-x>", toggle_markdown_checklist, { silent = true, desc = "cycle through todo list states" })
    vim.keymap.set("n", "<C-u>", move_up_checklist_item, { silent = true, desc = "move checklist item to top" })
    vim.api.nvim_create_user_command("Order", reorder, {})
  end,
  group = markdown_group,
})

vim.api.nvim_create_autocmd({ "BufEnter", "CursorMoved" }, {
  pattern = { "markdown", "vimwiki", "*.md" },
  group = markdown_group,
  callback = function()
    stats()
  end,
})

--
--
-- vimwiki and calendar
return {
  {
    "vimwiki/vimwiki",
    branch = "dev",
    dependencies = { "mattn/calendar-vim" },
    init = function()
      vim.g.vimwiki_list = {
        {
          path = "~/vimwiki/wiki",
          path_html = "~/vimwiki/wiki/public_html",
          auto_tags = 1,
          auto_diary_index = 1,
          syntax = "markdown",
          ext = ".md",
        },
      }
      vim.g.vimwiki_markdown_link_ext = 1
      vim.g.vimwiki_stripsym = " "
      vim.g.vimwiki_global_ext = 0
    end,
  },

  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      file_types = { "markdown", "vimwiki" },
    },
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" }, -- if you prefer nvim-web-devicons
  },
}
