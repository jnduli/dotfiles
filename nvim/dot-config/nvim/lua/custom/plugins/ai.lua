return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
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
}
