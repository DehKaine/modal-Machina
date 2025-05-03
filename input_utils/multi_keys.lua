
-- 多按键组合逻辑

local master_eventtap = require("master_eventtap")

-- ================================================ 映射表定义

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
    ["alt-;"] = { key = "right", mods = {"alt", "shift"} },
    ["alt-u"] = { key = "pageup", mods = {} },
    ["alt-o"] = { key = "pagedown", mods = {} },
    ["alt-y"] = { key = "up", mods = {"cmd"} },
    ["alt-p"] = { key = "down", mods = {"alt", "shift"} },
    -- ["shift-space"] = { key = "space", mods = {"cmd"} },
}

hs.hotkey.bind({"shift"}, "space", function()
    local current = hs.execute("/opt/homebrew/bin/im-select"):gsub("%s+", "")
    if current ~= "com.sougou.inputmethod.sogou.pinyin" then
        hs.execute("/opt/homebrew/bin/im-select com.sogou.inputmethod.sogou.pinyin")
    else
        hs.execute("/opt/homebrew/bin/im-select com.apple.keylayout.ABC")
    end
end)

-- ================================================ 核心处理函数

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

-- ================================================ 注册到master_eventtap
master_eventtap.register(handleMultiKey)

return {}