local menubar_widget = {}

local vim_statusbar = hs.menubar.new()

local function updateVimStatusbar()
    local label = "Awake"
    vim_statusbar:setTitle(label)
end

hs.hotkey.bind({"alt"}, "v", function()
    updateVimStatusbar()
end)

return menubar_widget