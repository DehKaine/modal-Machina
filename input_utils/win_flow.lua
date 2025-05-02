local win_flow = {}

local focus_map = {
    fw = "WeChat.app",
    fi = "Finder",
    fo = "Fork",
    fe = "Eagle",
    fg = "ChatGPT",
    fc = "Google Chrome",
    fv = "Visual Studio Code",
}

local function restoreMinimizedWindows(app)
    if not app then return end
    local wins = app:allWindows()
    for _, win in ipairs(wins) do
        if win:isMinimized() then
            win:unminimize()
            win:focus()
            break
        end
    end
end

function win_flow.focusToAppByCmd(cmd)
    local appName = focus_map[cmd]
    if appName then
        local app = hs.application.find(appName)
        if app then
            app:activate()
            restoreMinimizedWindows(app)
        else
            hs.application.launchOrFocus(appName)
        end
    end
end

function win_flow.restoreFrontmostApp()
    local app = hs.application.frontmostApplication()
    if app then
        restoreMinimizedWindows(app)
    end
end

return win_flow
