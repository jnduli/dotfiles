vim.treesitter.language.register("markdown", "vimwiki")

local markdown_group = vim.api.nvim_create_augroup("markdown_group", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "CursorMoved" }, {
  pattern = { "markdown", "vimwiki", "*.md" },
  group = markdown_group,
  callback = function()
    stats()
    highlight_delayed_tasks()
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

  { dir = "~/.config/nvim/personal_plugins/markdown_todo" },
}
