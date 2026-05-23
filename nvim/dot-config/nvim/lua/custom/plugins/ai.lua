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
}
