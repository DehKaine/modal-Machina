local master_eventtap = require("master_eventtap")
local vim_mode = require("vim_mode")

local media_controller = {}

local modal = hs.hotkey.modal.new({"alt"}, "m")

local mediaKeyMap = {
    ["a"] = "BRIGHTNESS_DOWN",
    ["s"] = "BRIGHTNESS_UP",
    ["d"] = "VOLUME_DOWN",
    ["f"] = "VOLUME_UP",
    ["g"] = "MUTE",
    ["h"] = "PLAY",
    ["j"] = "PREVIOUS",
    ["k"] = "NEXT",
}

local bgCanvas = nil
local eventtap = nil

local font = {
    name = "Monaco",
    size = 14,
    color = { white = 1, alpha = 0.8 },
}

local function drawPanel()
    if bgCanvas then
        bgCanvas:delete()
    end

    local screenFrame = hs.screen.mainScreen():frame()
    local width = 400
    local height = 120
    local x = screenFrame.x + (screenFrame.w - width) / 2
    local y = screenFrame.y + (screenFrame.h - height) / 2

    bgCanvas = hs.canvas.new{x = x, y = y, w = width, h = height}:show()
    bgCanvas:appendElements({
        type = "rectangle",
        action = "fill",
        fillColor = { red = 0, green = 0, blue = 0, alpha = 0.5 },
        roundedRectRadii = { xRadius = 10, yRadius = 10 },
    })

    local keys = {}
    for k, _ in pairs(mediaKeyMap) do
        table.insert(keys, k)
    end
    table.sort(keys)

    local keyCount = #keys
    local buttonWidth = width / keyCount
    local buttonHeight = height

    for i, key in ipairs(keys) do
        local label = key .. "\n" .. (mediaKeyMap[key] or "")

        bgCanvas:appendElements({
            {
                type = "rectangle",
                action = "stroke",
                strokeColor = { white = 1, alpha = 0.6 },
                strokeWidth = 1,
                frame = {
                    x = (i - 1) * buttonWidth,
                    y = 0,
                    w = buttonWidth,
                    h = buttonHeight,
                },
            },
            {
                type = "text",
                text = label,
                textFont = font.name,
                textSize = font.size,
                textColor = font.color,
                textAlignment = "center",
                frame = {
                    x = (i - 1) * buttonWidth,
                    y = 0,
                    w = buttonWidth,
                    h = buttonHeight,
                },
            }
        })
    end
end

local function triggerMedia(key)
    local action = mediaKeyMap[key]
    if not action then return end
    local event = hs.eventtap.event.newSystemKeyEvent(action, true)
    event:post()
    local eventUp = hs.eventtap.event.newSystemKeyEvent(action, false)
    eventUp:post()
end

local function mediaHandler(event)
    local key = event:getCharacters(true)
    if key == nil then return false end
    if mediaKeyMap[key] then
        triggerMedia(key)
        return true
    elseif key == "escape" then
        modal:exit()
        return true
    end
    return false
end

function modal:entered()
    if vim_mode then
        vim_mode.exitVim()
    end
    drawPanel()
    master_eventtap.register(mediaHandler)
end

function modal:exited()
    if bgCanvas then bgCanvas:delete() bgCanvas = nil end
    if eventtap then eventtap:stop() eventtap = nil end
    master_eventtap.unregister(mediaHandler)
end

modal:bind({},"escape",function ()
    modal:exit()
end)

-- hs.hotkey.bind({"alt"}, "b", function()
--     hs.alert.show("mute debug")
--     local key = "MUTE"
--     local event = hs.eventtap.event.newSystemKeyEvent(key, true)
--     event:post()
--     hs.timer.usleep(10000)
--     local eventUp = hs.eventtap.event.newSystemKeyEvent(key,false)
--     eventUp:post()
-- end)

return media_controller