local work_log = require("work_log.api")

local M = {}

function M.setup()
  vim.api.nvim_set_hl(0, "WorkLogComment", { fg = "Gray", italic = true, bold = false, default = true })
  vim.api.nvim_set_hl(0, "WorkLogRun", { fg = "Cyan", italic = true, bold = false, default = true })
  vim.api.nvim_set_hl(0, "WorkLogPause", { fg = "Yellow", italic = true, bold = false, default = true })
  vim.api.nvim_set_hl(0, "WorkLogComplete", { fg = "Green", italic = true, bold = false, default = true })
  vim.api.nvim_create_user_command("WorkLog", work_log.new_window, {})
  vim.api.nvim_create_user_command("WLReset", function ()
    package.loaded["work_log"] = nil
    package.loaded["work_log.api"] = nil
    require("work_log")
    require("work_log.api")
  end, {})
end

M.setup()

return M
