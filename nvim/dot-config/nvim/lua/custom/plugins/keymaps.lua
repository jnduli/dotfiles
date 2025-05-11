-- Additional Keymaps I find usefule
--

-- vimconfig easy editting
vim.keymap.set("n", "<leader>sv", ":source $MYVIMRC<cr>", { desc = "source main vimrc file" })
vim.keymap.set("n", "<leader>ov", ":vsplit <C-r>=resolve(expand($MYVIMRC))<cr><cr>", { desc = "open main vimrc file" })

-- path expanstions for easy navigation
vim.cmd("cabbr <expr> %f expand('%:p:h')")
vim.cmd("cabbr <expr> %% expand('%:h')")

return {}
