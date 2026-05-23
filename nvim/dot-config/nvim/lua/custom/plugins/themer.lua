local theme_state_file = vim.fn.expand('~/.cache/nvim-theme-state')

-- Store the watcher reference globally or on a custom namespace so it 
-- survives configuration hot-reloads without creating leaks.
_G._theme_watcher = _G._theme_watcher or nil

local function sync_theme()
    local f = io.open(theme_state_file, "r")
    if f then
        local mode = f:read("*all"):gsub("%s+", "")
        f:close()
        if mode == "light" or mode == "dark" then
            vim.o.background = mode
        end
    end
end

local function start_theme_watcher()
    local stat = vim.loop.fs_stat(theme_state_file)
    if not stat then
        vim.notify("Cannot watch theme: File does not exist at " .. tostring(theme_state_file), vim.log.levels.WARN)
        return
    end

    if _G._theme_watcher then
        _G._theme_watcher:stop()
        if not _G._theme_watcher:is_closing() then
            _G._theme_watcher:close()
        end
        _G._theme_watcher = nil
    end

    local w, err = vim.loop.new_fs_event()
    if not w then
        vim.notify("Failed to create fs_event watcher: " .. tostring(err), vim.log.levels.ERROR)
        return
    end

    _G._theme_watcher = w
    sync_theme()

    local success, start_err = w:start(theme_state_file, {}, vim.schedule_wrap(function(callback_err)
        if callback_err then
            vim.notify("File watch error: " .. tostring(callback_err), vim.log.levels.ERROR)
            return
        end

        sync_theme()
    end))

    if not success then
        vim.notify("Failed to start watcher: " .. tostring(start_err), vim.log.levels.ERROR)
        if not w:is_closing() then w:close() end
        _G._theme_watcher = nil
    end
end

return {
    "themer-watcher",
    dir = vim.fn.stdpath("config"), -- Point to a local directory so it doesn't look for a git repo
    config = function()
        start_theme_watcher()
    end
}




























