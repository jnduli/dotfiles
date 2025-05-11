local M = {}

local goto_random_line = function ()
  local line_no = vim.api.nvim_buf_line_count(0)
  local random = math.random(0, line_no)
  vim.cmd(string.format(":call cursor(%d, %d)", random, 1))
end

function M.say_line()
  local cmd = 'espeak -- "' .. vim.api.nvim_get_current_line() .. '"'
  vim.fn.system(cmd)
end

function M.github_path_link()
  -- Returns a path to github.com for the current line
  -- e.g. https://github.com/jnduli/dotfiles/blob/57ebd0145c85580a171285a4440b8d16e74c380c/i3/i3status_config#L14
  local originUrl = vim.fn.system('git config --get remote.origin.url')
  local mainBranch = vim.fn.system('git symbolic-ref --short refs/remotes/origin/HEAD')
  local mainHash = vim.fn.trim(vim.fn.system('git rev-parse ' .. mainBranch))
  local gitPathToFile = vim.fn.trim(vim.fn.system('git ls-files --full-name ' .. vim.fn.expand("%")))


  if gitPathToFile == nil or gitPathToFile == '' then
    error("File " .. vim.fn.expand("%") .. " is not a tracked git file")
  end

  local github_relative_path = vim.fn.split(originUrl, 'github.com:\\?')[2]
  local relative_path = vim.fn.split(github_relative_path, '\\.')[1]
  -- local relativeGithub = vim.fn.trim(vim.fn.split(vim.fn.split(originUrl, 'github.com:\\?')[2], '\.')[1])
  local path = 'https://github.com/' ..
      relative_path .. '/blob/' .. mainHash .. '/' .. gitPathToFile .. '#L' .. vim.fn.line(".")
  vim.cmd("let @+ = '" .. path .. "'")
end



M.setup = function()
  vim.api.nvim_create_user_command("RandomLine", goto_random_line, {})
  vim.api.nvim_create_user_command("GitLink", M.github_path_link, {})
  vim.api.nvim_create_user_command("Say", M.say_line, {})
  vim.api.nvim_create_user_command("MReload", function ()
    package.loaded["my_functions"] = nil
    local my_fns = require("my_functions")
    my_fns.setup()
  end

    , {})
end

return M

