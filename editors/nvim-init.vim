set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

" let g:python3_host_prog = '/usr/bin/python'


" Neovim lsp
lua << EOF
require'lspconfig'.pyright.setup{}
EOF

lua << EOF
local nvim_lsp = require('lspconfig')    

-- Use an on_attach function to only map the following keys    
-- after the language server attaches to the current buffer    
local on_attach = function(client, bufnr)    
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end    
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end    

  -- Enable completion triggered by <c-x><c-o>    
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')    

  -- Mappings.    
  local opts = { noremap=true, silent=true }    

  -- See `:help vim.lsp.*` for documentation on any of the below functions    
  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)    
  buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)    
  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)    
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)    
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)    
  buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)    
  buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)    
  buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)    
  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)    
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)    
  buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)    
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)    
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)    
  buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)    
  buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)    
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.set_loclist()<CR>', opts)    
  vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true} end, opts)    
end    
-- Use a loop to conveniently call 'setup' on multiple servers and    
-- map buffer local keybindings when the language server attaches    
local servers = { 'pyright', 'rust_analyzer', 'tsserver', 'bashls' }    
for _, lsp in ipairs(servers) do    
  nvim_lsp[lsp].setup {    
    on_attach = on_attach,    
    flags = {    
      debounce_text_changes = 150,    
    }    
  }    

-- diagnostics
vim.lsp.handlers["textDocument/publishDiagnostics"] =
    vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
        -- Disable underline, it's very annoying
        underline = false,
        -- virtual_text = false,
        -- Enable virtual text, override spacing to 4
        -- virtual_text = {spacing = 4},
        -- Use a function to dynamically turn signs off
        -- and on, using buffer local variables
        -- signs = true,
        -- update_in_insert = false
    })
end    
EOF

" Neovim treesitter
lua <<EOF
require'nvim-treesitter.configs'.setup {
    ensure_installed = { "bash", "dockerfile", "go", "ledger", "lua", "markdown", "python", "rust", "sql", "vim", "yaml" },
  highlight = {
    enable = true,              -- false will disable the whole extension
    -- disable = {"ledger", }, made the file smaller
    -- disable = { "c", "rust" },  -- list of language that will be disabled
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
    -- additional_vim_regex_highlighting = { "python", },
  },
  indent = {
    enable = true,
    disable = {"python", },
  },

  playground = {
    enable = true,
    disable = {},
    updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
    persist_queries = false, -- Whether the query persists across vim sessions
    keybindings = {
      toggle_query_editor = 'o',
      toggle_hl_groups = 'i',
      toggle_injected_languages = 't',
      toggle_anonymous_nodes = 'a',
      toggle_language_display = 'I',
      focus_language = 'f',
      unfocus_language = 'F',
      update = 'R',
      goto_node = '<cr>',
      show_help = '?',
    },
  }
}
EOF

" Neovim treesitter
lua <<EOF
local iron = require("iron.core")
local view = require("iron.view")

iron.setup {
  config = {
    -- Whether a repl should be discarded or not
    scratch_repl = true,
    -- Your repl definitions come here
    repl_definition = {
      sh = {
        -- Can be a table or a function that
        -- returns a table (see below)
        command = {"zsh"}
      }
    },
    -- How the repl window will be displayed
    -- See below for more information
    repl_open_cmd = view.split("40%")
  },
  -- Iron doesn't set keymaps by default anymore.
  -- You can set them here or manually add keymaps to the functions in iron.core
  keymaps = {
    send_motion = "<space>sc",
    visual_send = "<space>sc",
    send_file = "<space>sf",
    send_line = "<space>sl",
    send_mark = "<space>sm",
    mark_motion = "<space>mc",
    mark_visual = "<space>mc",
    remove_mark = "<space>md",
    cr = "<space>s<cr>",
    interrupt = "<space>s<space>",
    exit = "<space>sq",
    clear = "<space>cl",
  },
  -- If the highlight is on, you can change how it looks
  -- For the available options, check nvim_set_hl
  highlight = {
    italic = true
  },
  ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
}

-- iron also has a list of commands, see :h iron-commands for all available commands
vim.keymap.set('n', '<space>rs', '<cmd>IronRepl<cr>')
vim.keymap.set('n', '<space>rr', '<cmd>IronRestart<cr>')
vim.keymap.set('n', '<space>rf', '<cmd>IronFocus<cr>')
vim.keymap.set('n', '<space>rh', '<cmd>IronHide<cr>')

EOF

let g:neon_style = "dark"
" colorscheme neon
colorscheme kanagawa


