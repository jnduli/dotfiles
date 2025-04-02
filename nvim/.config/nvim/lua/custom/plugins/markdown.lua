vim.treesitter.language.register("markdown", "vimwiki")
vim.g.markdown_folding = 1

DONE_CHECKLIST = "- [X]"
OPEN_CHECKLIST = "- [ ]"

local function move_up_checklist_item(lnum)
  if not lnum then
    lnum = vim.fn.getcurpos()[2] - 1
  end
  local up_lnum = lnum - 1
  while up_lnum > 0 do
    local current_line = vim.api.nvim_buf_get_lines(0, up_lnum, up_lnum + 1, false)[1]
    local status = string.sub(current_line, 1, string.len(DONE_CHECKLIST))
    if status == DONE_CHECKLIST then
      break
    end
    if status ~= DONE_CHECKLIST and status ~= OPEN_CHECKLIST then
      break
    end
    up_lnum = up_lnum - 1
  end

  local line = vim.api.nvim_buf_get_lines(0, lnum, lnum + 1, false)[1]
  vim.print("Moving " .. line .. " from: " .. lnum .. " to: " .. up_lnum)
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
  vim.print(current_check)
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
          path = "~/vimwiki",
          path_html = "~/vimwiki/public_html",
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
