-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({

  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  -- NOTE: This is where your plugins related to LSP can be installed.
  --  The configuration is done below. Search for lspconfig to find it below.
  { -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim',       tag = 'legacy', opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
  },

  { -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = { 'hrsh7th/cmp-nvim-lsp', 'L3MON4D3/LuaSnip', 'saadparwaiz1/cmp_luasnip' },
  },

  -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim',          opts = {} },
  { -- Adds git releated signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },

  -- Themes
  { -- Theme inspired by Atom
    'navarasu/onedark.nvim',
    priority = 1000,
    config = function()
      vim.g.onedark_config = { style = 'darker', }
      -- vim.cmd.colorscheme 'onedark'
    end,
  },
  {
    "neanias/everforest-nvim",
    -- Optional; default configuration will be used if setup isn't called.
    config = function()
      require("everforest").setup({
        background = "hard",
      })
      vim.cmd.colorscheme 'everforest'
    end,
  },


  -- {
  --   "aktersnurra/no-clown-fiesta.nvim",
  --   priority = 1000,
  --   config = function()
  --     local opts = {
  --       transparent = true,
  --       styles = {
  --         type = { bold = true },
  --         lsp = { underline = false },
  --         match_paren = { underline = true },
  --       },
  --     }
  --     local plugin = require "no-clown-fiesta"
  --     plugin.setup(opts)
  --     vim.cmd.colorscheme 'no-clown-fiesta'
  --     return plugin.load()
  --   end,
  --   lazy = false,
  -- },



  { -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = false,
        theme = 'everforest',
        component_separators = '|',
        section_separators = '',
      },
    },
  },
  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help indent_blankline.txt`
    main = "ibl",
    opts = {},
  },

  -- {
  --   -- Add indentation guides even on blank lines
  --   'lukas-reineke/indent-blankline.nvim',
  --   -- Enable `lukas-reineke/indent-blankline.nvim`
  --   -- See `:help indent_blankline.txt`
  --   config = function()
  --     require('ibl').setup {
  --       char = '┊',
  --       show_trailing_blankline_indent = false,
  --     }
  --   end,
  -- },

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim',         opts = {} },

  -- Fuzzy Finder (files, lsp, etc)
  { 'nvim-telescope/telescope.nvim', version = '*', dependencies = { 'nvim-lua/plenary.nvim' } },

  -- Fuzzy Finder Algorithm which requires local dependencies to be built.
  -- Only load if `make` is available. Make sure you have the system
  -- requirements installed.
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    -- NOTE: If you are having trouble with this installation,
    --       refer to the README for telescope-fzf-native for more instructions.
    build = 'make',
    cond = function()
      return vim.fn.executable 'make' == 1
    end,
  },

  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ":TSUpdate",
  },

  -- ledger support
  'ledger/vim-ledger',

  -- fork after original was archived "jose-elias-alvarez/null-ls.nvim",
  'nvimtools/none-ls.nvim',

  -- support for chaging surround params
  'tpope/vim-surround',

  -- vimwiki and calendar
  {
    'vimwiki/vimwiki',
    branch = 'dev',
    dependencies = { 'mattn/calendar-vim' },
    init = function()
      vim.g.vimwiki_list = {
        { path = "~/vimwiki", path_html = "~/vimwiki/public_html", auto_tags = 1, auto_diary_index = 1, syntax = 'markdown', ext = '.md' }, }
      vim.g.vimwiki_markdown_link_ext = 1
      vim.g.vimwiki_stripsym = ' '
      vim.g.vimwiki_global_ext = 0
    end
  },
  'dense-analysis/ale',

  -- harpoon
  { 'ThePrimeagen/harpoon', version = '*',                                    dependencies = { 'nvim-lua/plenary.nvim' } },

  { "folke/trouble.nvim",   dependencies = { "nvim-tree/nvim-web-devicons" }, opts = {}, },

  {
    "m4xshen/hardtime.nvim",
    dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
    opts = {
      restricted_keys = {
        -- I use this in harpoon
        ["<C-N>"] = { "x" },
        ["<C-P>"] = { "x" },
      },
    }
  },
  -- -- Experimental for UI elements
  -- ---
  {
    'stevearc/dressing.nvim',
    opts = {},
  },
  -- -- file organization
  {
    'stevearc/oil.nvim',
    opts = {},
    -- Optional dependencies
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },

  {
    "tpope/vim-dadbod",
    "kristijanhusak/vim-dadbod-completion",
    "kristijanhusak/vim-dadbod-ui",
  },

  {
    "kawre/leetcode.nvim",
    build = ":TSUpdate html",
    -- cmd = "Leet",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim", -- required by telescope
      "MunifTanjim/nui.nvim",

      -- optional
      "nvim-treesitter/nvim-treesitter",
      "rcarriga/nvim-notify",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      lang = "python3"
    },
  },
  {
    "mistweaverco/kulala.nvim",
    opts = {
      default_view = "headers_body"
    }
  },

  {
    'MeanderingProgrammer/render-markdown.nvim',
    opts = {
      file_types = { "markdown", "vimwiki" }
    },
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
  },

  -- disable features in big files
  {
    "LunarVim/bigfile.nvim",
  },
  -- chat support trial
  {
    "robitx/gp.nvim",
    config = function()
      local conf = {
        providers = {
          googleai = {
            disable = false,
            endpoint =
            "https://generativelanguage.googleapis.com/v1beta/models/{{model}}:streamGenerateContent?key={{secret}}",
            secret = os.getenv("GOOGLE_API_KEY"),
          },
        },
        default_chat_agent = "ChatGemini",
        -- default_command_agent
      }
      require("gp").setup(conf)
    end,
  },

  -- work log support
  {
    dir = "~/.config/nvim/personal_plugins/work_log",
  },
  {
    dir = "~/.config/nvim/personal_plugins/ai_helper",
    dependencies = { 'nvim-lua/plenary.nvim' }
  },
  {
    dir = "~/vimwiki/scripts/camaraderie",
    config = function()
      require("camaraderie").setup()
    end,
  },


  --
  -- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins" for kickstart
  --       These are some example plugins that I've included in the kickstart repository.
  --       Uncomment any of the lines below to enable them.
  -- require 'kickstart.plugins.autoformat',
  -- require 'kickstart.plugins.debug',

  -- NOTE: The import below automatically adds your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
  --    up-to-date with whatever is in the kickstart repo.
  --
  --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
  --
  --    An additional note is that if you only copied in the `init.lua`, you can just comment this line
  --    to get rid of the warning telling you that there are not plugins in `lua/custom/plugins/`.
  -- { import = 'custom.plugins' },
  --
  --
  --
}, {})

-- [[ Setting options ]]
-- See `:help vim.o`

-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
vim.wo.number = true

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Tabs occupy 4 spaces instead of 8
vim.o.tabstop = 4

-- Save undo history
vim.o.undofile = true

-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeout = true
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- mode is already shown using lualine. Disabled so that I can see visual mode messages
vim.o.showmode = false

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
      },
    },
  },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sgr', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sgi', require('telescope.builtin').git_files, { desc = '[S]earch [D]iagnostics' })

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
require('nvim-treesitter.configs').setup {
  -- Add languages to be installed here that you want installed for treesitter
  ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'typescript', 'vimdoc', 'vim', 'markdown', 'markdown_inline', 'org' },

  -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
  auto_install = false,



  -- ref: https://github.com/nvim-treesitter/nvim-treesitter/issues/1573#issuecomment-2202945329
  highlight = {
    enable = true,
    -- additional_vim_regex_highlighting = { "python" },
  },
  indent = { enable = true },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<c-space>',
      node_incremental = '<c-space>',
      scope_incremental = '<c-s>',
      node_decremental = '<M-space>',
    },
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ['<leader>a'] = '@parameter.inner',
      },
      swap_previous = {
        ['<leader>A'] = '@parameter.inner',
      },
    },
  },
}
vim.treesitter.language.register('markdown', 'vimwiki')

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

-- LSP settings.
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format { timeout_ms = 2000 }
  end, { desc = 'Format current buffer with LSP' })
end

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
local servers = {
  -- clangd = {},
  bashls = {},
  pyright = {},
  rust_analyzer = {
    ["rust-analyzer"] = {
      checkOnSave = {
        command = "clippy",
      },
    },
  },
  -- tsserver = {},

  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- require("mason").setup {
--     log_level = vim.log.levels.DEBUG
-- }

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

-- local null_ls = require 'null-ls'
-- null_ls.setup({
--   sources = {
--     null_ls.builtins.formatting.black,
--     null_ls.builtins.formatting.isort,
--   }
-- })

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
    }
  end,
}

-- nvim-cmp setup
local cmp = require 'cmp'
local luasnip = require 'luasnip'

require("luasnip.loaders.from_snipmate").load({ paths = { "~/.config/nvim/mysnippets/" } })

luasnip.config.setup {}

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}

-- vimconfig easy editting
vim.keymap.set('n', '<leader>sv', ":source $MYVIMRC<cr>", { desc = "source main vimrc file" })
vim.keymap.set('n', '<leader>ov', ":vsplit <C-r>=resolve(expand($MYVIMRC))<cr><cr>", { desc = "open main vimrc file" })

-- ledger configs
vim.g.ledger_bin = 'ledger'
vim.g.ledger_extra_options = '--pedantic --explicit --check-payees'
vim.g.ledger_default_commodity = 'Ksh'
vim.g.ledger_commodity_sep = ' '  -- Should be a space btn default commodity and amount
vim.g.ledger_commodity_before = 1 -- Default commodity prepended to amount
vim.g.ledger_align_at = 60        -- sets up the column of aligning decimal point
local ledger_group = vim.api.nvim_create_augroup('ledger_group', { clear = true })
vim.api.nvim_create_autocmd('Filetype', {
  pattern = { 'ledger', },
  callback = function()
    vim.keymap.set('v', '<Tab>', ':LedgerAlign<CR>', { silent = true, desc = 'align ledger file columns' })
  end,
  group = ledger_group,
})
vim.keymap.set('n', '<leader>o$', ":tabnew ~/docs/ledger/blackbook.ledger<cr>", { desc = "open ledger file" })

-- nvim terminal configs
vim.api.nvim_create_autocmd('TermOpen', {
  callback = function()
    vim.keymap.set('t', '<Esc>', '<c-\\><c-n>', { buffer = true, desc = 'escape works in terminal' })
    vim.keymap.set('t', '<A-h>', '<C-\\><C-N><C-w>h', { buffer = true })
    vim.keymap.set('t', '<A-j>', '<C-\\><C-N><C-w>j', { buffer = true })
    vim.keymap.set('t', '<A-k>', '<C-\\><C-N><C-w>k', { buffer = true })
    vim.keymap.set('t', '<A-l>', '<C-\\><C-N><C-w>l', { buffer = true })
    vim.keymap.set('t', '<A-h>', '<C-\\><C-N><C-w>h', { buffer = true })
    vim.keymap.set('t', '<A-j>', '<C-\\><C-N><C-w>j', { buffer = true })
    vim.keymap.set('t', '<A-k>', '<C-\\><C-N><C-w>k', { buffer = true })
    vim.keymap.set('t', '<A-l>', '<C-\\><C-N><C-w>l', { buffer = true })
  end,
})

--  easy switching of windows
vim.keymap.set('n', '<A-h>', '<C-w>h')
vim.keymap.set('n', '<A-j>', '<C-w>j')
vim.keymap.set('n', '<A-k>', '<C-w>k')
vim.keymap.set('n', '<A-l>', '<C-w>l')

local my_fns = require("my_functions")
my_fns.setup()

vim.keymap.set('n', '<leader>G', my_fns.github_path_link, { desc = 'get github path link' })

-- ALE concigs
vim.g.ale_fixers = {
  python = { 'remove_trailing_lines', 'trim_whitespace' },
  ledger = { 'trim_whitespace' },
  terraform = { 'terraform' },
  rust = { 'rustfmt' },
}
vim.g.ale_fix_on_save = 1

-- path expansions for command mode
vim.cmd("cabbr <expr> %f expand('%:p:h')")
vim.cmd("cabbr <expr> %% expand('%:h')")

vim.opt.relativenumber = true
vim.wo.numberwidth = 2
vim.o.autoread = true
vim.opt.colorcolumn = "80,120"
vim.opt.scrolloff = 8

-- force wrapping of lines in plain text files at 80 char limit
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { '*.txt', '*md', '*.rst', '*.text', '*.wiki', '*.vimwiki' },
  callback = function()
    vim.bo.textwidth = 80
  end
})

-- Added because with indent_blankline the cursor isn't visible on indent markers
-- ref: https://github.com/lukas-reineke/indent-blankline.nvim/issues/115
vim.opt.guicursor =
"n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175"
vim.cmd("highlight Cursor gui=NONE guifg=bg guibg=fg")

-- coomand mode options to support bash like completion
vim.o.wildmenu = true
vim.o.wildmode = "longest:full"
vim.keymap.set('c', '<C-k>', '<UP>', { desc = 'find last command in command mode with C-K' })

-- copied from primeagen
--
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("x", "<leader>p", [["_dP]])


-- harpoon setup
local mark = require("harpoon.mark")
local ui = require("harpoon.ui")

vim.keymap.set("n", "<leader>m", mark.add_file)
vim.keymap.set("n", "<C-e>", ui.toggle_quick_menu)

-- vim.keymap.set("n", "<C-h>", function() ui.nav_file(1) end)
vim.keymap.set("n", "<C-t>", function() ui.gotoTerminal(1) end)
vim.keymap.set("n", "<C-n>", function() ui.nav_next() end)
vim.keymap.set("n", "<C-p>", function() ui.nav_prev() end)
-- vim.keymap.set("n", "<C-n>", function() ui.nav_file(3) end)
-- vim.keymap.set("n", "<C-s>", function() ui.nav_file(4) end)

-- attempts to implement the functionality in https://github.com/redahe/vim-espeaker/blob/master/plugin/espeaker.vim
--
vim.keymap.set("n", "<C-s>", my_fns.say_line)

require("dressing").setup({
  input = {
    -- When true, <Esc> will close the modal
    insert_only = false,

    -- When true, input will start in insert mode.
    start_in_insert = false,

  },
})

require("oil").setup()

-- kulala set up
vim.filetype.add({
  extension = {
    ['http'] = 'http',
  },
})


require("work_log")
require("ai_helper")

-- markdown cycle through todo list items
local function toggle_markdown_checklist()
  local current_cursor = vim.fn.getcurpos()
  local current_line = vim.api.nvim_buf_get_lines(0, current_cursor[2] - 1, current_cursor[2], false)[1]
  local next_checklist_table = { ["[ ]"] = "[-]", ["[-]"] = "[X]", ["[X]"] = "[~]", ["[~]"] = "[ ]" }
  local dash_col, _ = string.find(current_line, "[-*]")
  if dash_col == nil then
    return
  end
  local current_check = vim.api.nvim_buf_get_text(0, current_cursor[2] - 1, dash_col + 1, current_cursor[2] - 1,
    dash_col + 4, {})[1]
  local next_content = next_checklist_table[current_check]
  if next_content == nil then
    return
  end
  vim.api.nvim_buf_set_text(0, current_cursor[2] - 1, dash_col + 1, current_cursor[2] - 1, dash_col + 4, { next_content })
  vim.fn.setpos('.', current_cursor)
end

local markdown_group = vim.api.nvim_create_augroup('markdown_group', { clear = true })
vim.api.nvim_create_autocmd('Filetype', {
  pattern = { 'markdown', },
  callback = function()
    vim.keymap.set('n', '<C-x>', toggle_markdown_checklist, { silent = true, desc = 'cycle through todo list states' })
  end,
  group = markdown_group,
})


require("notify").setup({ timeout = 1000 })


-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
