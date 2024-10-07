local work_log = require("work_log.api")

local M = {}

function M.setup()
  vim.api.nvim_create_user_command("WorkLog", work_log.new_window, {})
end

M.setup()

return M
