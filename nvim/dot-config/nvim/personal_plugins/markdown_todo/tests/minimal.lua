local root = vim.fn.fnamemodify(".", ":p")
vim.opt.rtp:append(root)
-- Ensure Plenary is in the path (adjust path if using a different manager)
vim.opt.rtp:append(vim.fn.stdpath("data") .. "/lazy/plenary.nvim")
