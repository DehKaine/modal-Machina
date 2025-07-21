-- 单按键的自定义逻辑

local master_eventtap = require("master_eventtap")

-- ================================================ 映射表定义

-- 无修饰键映射
local noModMap = {
    -- ["'"] = "=",
    ["/"] = "!",
}

-- shift组合键映射
local shiftModMap = {
    -- ["-"] = "+",
    -- ["§"] = ":", 会被vim的launcher影响，多发送一个shift事件，改用karabiner设置
    ["="] = "\"",
}

-- alt组合键映射
local altModMap = {
    ["-"] = {mods = {"shift"}, key = "2"},
    -- ["'"] = ";",
    -- ["/"] = "!",
    ["["] = "'",
    ["]"] = "`",
    ["\\"] = "~",
}

-- ================================================ 核心处理函数

local function handleSingleKey(event)
    local mods = event:getFlags()
    local keyCode = event:getKeyCode()

    -- 无修饰键
    if not mods.ctrl and not mods.alt and not mods.shift and not mods.cmd then
        for from, to in pairs(noModMap) do
            if keyCode == hs.keycodes.map[from] then
                hs.eventtap.keyStrokes(to)
                return true
            end
        end
    end

    -- shift组合键
    if mods.shift and not mods.alt and not mods.ctrl and not mods.cmd then
        for from, to in pairs(shiftModMap) do
            if keyCode == hs.keycodes.map[from] then
                hs.eventtap.keyStrokes(to)
                return true
            end
        end
    end

    -- alt组合键
    if mods.alt and not mods.shift and not mods.ctrl and not mods.cmd then
        for from, to in pairs(altModMap) do
            if keyCode == hs.keycodes.map[from] then
                if type(to) == "table" then
                    hs.eventtap.keyStroke(to.mods, to.key, 0)
                else
                    local originalClipboard = hs.pasteboard.getContents()
                    hs.pasteboard.setContents(to)
                    hs.eventtap.keyStroke({"cmd"}, "v", 0)
                    hs.timer.doAfter(0.1, function()
                        hs.pasteboard.setContents(originalClipboard)
                    end)
                end
                return true
            end
        end
    end

    return false
end

-- ================================================ 注册到master_eventtap
master_eventtap.register(handleSingleKey)

-- hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(event)
--   hs.alert.show("KeyCode: " .. event:getKeyCode())
--   return false
-- end):start()

return {}