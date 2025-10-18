return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      adapters = {
        acp = {
          gemini_cli = function()
            return require("codecompanion.adapters").extend("gemini_cli", {
              defaults = {
                auth_method = "gemini-api-key", -- "oauth-personal"|"gemini-api-key"|"vertex-ai"
              },
              env = {
                api_key = "GEMINI_API_KEY",
              },
            })
          end,
        },
      },
      strategies = {
        chat = {
          adapter = "gemini",
          env = {
            api_key = "GEMINI_API_KEY",
          },
        },
        inline = {
          adapter = "gemini",
          env = {
            api_key = "GEMINI_API_KEY",
          },
        },
      },
      opts = {
        -- Set debug logging
        log_level = "DEBUG",
      },
    },
  },
  {
    "zbirenbaum/copilot.lua",
    dependencies = {
      "copilotlsp-nvim/copilot-lsp",
      init = function()
        vim.g.copilot_nes_debounce = 500
        vim.lsp.enable("copilot_ls")
      end,
    },
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        workspace_folders = {
          "/home/rookie/vimwiki/",
        },
        filetypes = {
          markdown = false,
          vimwiki = false,
        },
        nes = {
          enabled = true, -- requires copilot-lsp as a dependency
          auto_trigger = true,
          keymap = {
            accept_and_goto = "<Tab>",
            accept = false,
            dismiss = "<Esc>",
          },
        },
      })
    end,
  },
}
