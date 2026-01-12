local markdown_todo = require("markdown_todo")

local markdown_group = vim.api.nvim_create_augroup("markdown_group", { clear = true })
vim.api.nvim_create_autocmd("Filetype", {
  pattern = { "markdown", "vimwiki", "*.md" },
  callback = function()
    markdown_todo.create_stats_highlight_groups()
    vim.bo.textwidth = 120
    vim.keymap.set(
      "n",
      "<C-x>",
      markdown_todo.toggle_markdown_checklist,
      { silent = true, desc = "cycle through todo list states" }
    )
    vim.keymap.set(
      "n",
      "<C-u>",
      markdown_todo.move_up_checklist_item,
      { silent = true, desc = "move checklist item to top" }
    )
    vim.api.nvim_create_user_command("Order", markdown_todo.reorder, {})
  end,
  group = markdown_group,
})

vim.api.nvim_create_autocmd({ "BufEnter", "CursorMoved" }, {
  pattern = { "markdown", "vimwiki", "*.md" },
  group = markdown_group,
  callback = function()
    markdown_todo.stats()
    markdown_todo.highlight_delayed_tasks()
  end,
})

vim.api.nvim_create_user_command("Add", function(opts)
  require("calc").calculate_and_print(opts)
end, { nargs = "*" })
