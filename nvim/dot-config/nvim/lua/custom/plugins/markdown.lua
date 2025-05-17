vim.treesitter.language.register("markdown", "vimwiki")

local log_level = "info" -- change to debug for more logs
local log = require("plenary.log").new({
  -- logs stored in echo stdpath("log")/custom_markdown.log
  plugin = "custom_markdown",
  level = log_level,
})

DONE_CHECKLIST = "- [X]"
OPEN_CHECKLIST = "- [ ]"

local CHECKLIST_STATUS = {
  OPEN = 1,
  DONE = 2,
  UNKNOWN = 3,
}

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
end

local STATS_NAMESPACE_ID = vim.api.nvim_create_namespace("StatsVirtualTextNamespace")
local STATS_HIGHLIGHT_GROUP = "StatsHighlight"
local global_stats_ext_mark = nil
local global_top_line_index = nil

vim.api.nvim_set_hl(0, "WeakStatsHighlight", { fg = "white", bg = "red", bold = true })
vim.api.nvim_set_hl(0, "GrowingStatsHighlight", { fg = "black", bg = "orange", bold = true })
vim.api.nvim_set_hl(0, "StrongStatsHighlight", { fg = "black", bg = "yellow", bold = true })
vim.api.nvim_set_hl(0, "OptimalStatsHighlight", { fg = "white", bg = "green", bold = true })

local function get_stats_highlight(ratio)
  if ratio == nil or ratio < 0.2 then
    return "WeakStatsHighlight"
  elseif ratio < 0.6 then
    return "GrowingStatsHighlight"
  elseif ratio < 0.9 then
    return "StrongStatsHighlight"
  else
    return "OptimalStatsHighlight"
  end
end

local function stats()
  local buf = vim.api.nvim_get_current_buf()

  local winline = vim.fn.winline() -- get current line relative to the top of the window
  local current_cursor = vim.fn.getcurpos()
  local current_line = current_cursor[2] -- get current line relative to the whole file
  local line_with_stats = current_line - winline
  if global_top_line_index == line_with_stats and not vim.bo.modified then
    return
  end

  if global_stats_ext_mark ~= nil then
    vim.api.nvim_buf_del_extmark(buf, STATS_NAMESPACE_ID, global_stats_ext_mark)
  end

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
  local stats_msg = string.format("%d/%d, %.2f", done, total, ratio)
  local stats_highlight = get_stats_highlight(ratio)

  global_top_line_index = line_with_stats
  global_stats_ext_mark = vim.api.nvim_buf_set_extmark(buf, STATS_NAMESPACE_ID, line_with_stats, 0, {
    virt_text = { { stats_msg, stats_highlight } },
    virt_text_pos = "eol_right_align",
  })
end

local markdown_group = vim.api.nvim_create_augroup("markdown_group", { clear = true })
vim.api.nvim_create_autocmd("Filetype", {
  pattern = { "markdown", "vimwiki" },
  callback = function()
    vim.bo.textwidth = 80
    vim.keymap.set("n", "<C-x>", toggle_markdown_checklist, { silent = true, desc = "cycle through todo list states" })
    vim.keymap.set("n", "<C-u>", move_up_checklist_item, { silent = true, desc = "move checklist item to top" })
  end,
  group = markdown_group,
})

vim.api.nvim_create_autocmd({ "BufEnter", "CursorMoved" }, {
  pattern = { "*.md" },
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
