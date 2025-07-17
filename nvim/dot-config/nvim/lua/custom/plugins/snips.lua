local snipmate_loader = require("luasnip.loaders.from_snipmate")

snipmate_loader.load()

local vimwiki_snippets = vim.fn.expand("~/vimwiki/snippets/")

if vim.fn.isdirectory(vimwiki_snippets) == 1 then
  snipmate_loader.lazy_load({ paths = vimwiki_snippets })
end

return {}
