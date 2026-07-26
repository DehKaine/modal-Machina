
local master_eventtap = require("master_eventtap")

local multiKeyMap = {
    ["ctrl-j"] = { key = "left", mods = {} },
    ["ctrl-k"] = { key = "down", mods = {} },
    ["ctrl-l"] = { key = "right", mods = {} },
    ["ctrl-i"] = { key = "up", mods = {} },
    ["ctrl-h"] = { key = "left", mods = {"shift"} },
    ["ctrl-;"] = { key = "right", mods = {"shift"} },
    ["ctrl-u"] = { key = "left", mods = {"cmd"} },
    ["ctrl-o"] = { key = "right", mods = {"cmd"} },
    ["ctrl-y"] = { key = "left", mods = {"cmd", "shift"} },
    ["ctrl-p"] = { key = "right", mods = {"cmd", "shift"} },
    ["ctrl-r"] = { key = "z", mods = {"cmd"} },
    ["ctrl-x"] = { key = "x", mods = {"cmd"} },
    ["ctrl-c"] = { key = "c", mods = {"cmd"} },
    ["ctrl-v"] = { key = "v", mods = {"cmd"} },
    ["ctrl-space"] = { key = "return", mods = {} },
    ["ctrl-delete"] = { key = "delete", mods = {"cmd"} },

    ["alt-j"] = { key = "left", mods = {"alt"} },
    ["alt-k"] = { key = "down", mods = {"alt"} },
    ["alt-l"] = { key = "right", mods = {"alt"} },
    ["alt-i"] = { key = "up", mods = {"alt"} },
    ["alt-h"] = { key = "left", mods = {"alt", "shift"} },
    ["alt-§"] = { key = "right", mods = {"alt", "shift"} },
    ["alt-u"] = { key = "pageup", mods = {} },
    ["alt-o"] = { key = "pagedown", mods = {} },
    ["alt-y"] = { key = "up", mods = {"cmd"} },
    ["alt-p"] = { key = "down", mods = {"alt", "shift"} },
}

local function handleMultiKey(event)
    local mods = event:getFlags()
    local key = hs.keycodes.map[event:getKeyCode()]
    if not key then return false end

    local modKeys = {}
    if mods.ctrl then table.insert(modKeys, "ctrl") end
    if mods.alt then table.insert(modKeys, "alt") end
    if mods.shift then table.insert(modKeys, "shift") end
    if mods.cmd then table.insert(modKeys, "cmd") end

    if #modKeys == 0 then return false end

    local combo = table.concat(modKeys, "-") .. "-" .. key
    local mapping = multiKeyMap[combo]
    if mapping then
        hs.eventtap.keyStroke(mapping.mods, mapping.key, 0)
        return true
    end

    return false
end

master_eventtap.register(handleMultiKey)

-- haycl3n's personal keymap

-- 优雅且无闪烁的输入法切换函数 (解决焦点错乱与切窗口闪烁)
local function switchInputMethod()
    local sogou = "com.sogou.inputmethod.sogou.pinyin"
    local abc   = "com.apple.keylayout.ABC"
    
    local current = hs.keycodes.currentSourceID()
    local targetIM = (current ~= sogou) and sogou or abc

    hs.keycodes.currentSourceID(targetIM)

    -- 微刷当前焦点输入框的 Text Context，刷新焦点且不闪烁屏幕
    hs.eventtap.event.newEventWithType(hs.eventtap.event.types.flagsChanged, 0):post()
end

hs.hotkey.bind({"shift"}, "space", function()
    switchInputMethod()
end)

local function simulatePsZoom(delta)
   local event = hs.eventtap.event.newScrollEvent({0, delta}, {}, "line")
   event:setFlags({alt = true})
   event:post()
end

hs.hotkey.bind({"ctrl"}, "pageup", function ()
    simulatePsZoom(3)
end)

hs.hotkey.bind({"ctrl"}, "pagedown", function ()
    simulatePsZoom(-3)
end)

return {}