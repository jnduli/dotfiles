## AI Helper: Enhance Your Code Comments

This tool helps you rewrite your documentation and comments with a more polished tone using AI.
**Setup:**
1. **Environment Variable:** Set `GOOGLE_API_KEY` to your Google API key.
```bash
export GOOGLE_API_KEY=abcde
```
2. **Lua Configuration:** Add the following to your Lua configuration file (e.g., Lazy.nvim):
```lua
  {
    dir = "~/.config/nvim/personal_plugins/ai_helper",
    dependencies = { 'nvim-lua/plenary.nvim' }
  },
```
**Usage:**
1. **Select Text:** Highlight the code comments or documentation you want to improve.
2. **Command:** Type `:Ai` in Vim command mode. The command will appear as `:'<,'>Ai`.

That's it! The AI Helper will rewrite the selected text, making your code more readable and professional. 
