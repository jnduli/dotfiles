local ledger_group = vim.api.nvim_create_augroup("ledger_group", { clear = true })
vim.api.nvim_create_autocmd("Filetype", {
  pattern = { "ledger" },
  callback = function()
    vim.g.ledger_bin = "ledger"
    vim.g.ledger_extra_options = "--pedantic --explicit --check-payees"
    vim.g.ledger_default_commodity = "Ksh"
    vim.g.ledger_commodity_sep = " " -- Should be a space btn default commodity and amount
    vim.g.ledger_commodity_before = 1 -- Default commodity prepended to amount
    vim.g.ledger_align_at = 60 -- sets up the column of aligning decimal point

    vim.keymap.set("v", "<Tab>", ":LedgerAlign<CR>", { silent = true, desc = "align ledger file columns" })
  end,
  group = ledger_group,
})
vim.keymap.set("n", "<leader>o$", ":tabnew ~/vimwiki/ledger/blackbook.ledger<cr>", { desc = "open ledger file" })

return {
  "ledger/vim-ledger",
}
