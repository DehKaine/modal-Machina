local master_eventtap = require("master_eventtap")
local vim_mode = require("vim_mode")

local media_controller = {}

local mediaKeys = {
    b = "brightness_down",
    n = "brightness_up",
    m = "volume_decrement",
    comma = "volume_increment",
    period = "mute",
    space = "playpause",
    left = "previous",
    right = "next",
}

local bgCanvas = nil
local eventtap = nil

local font = {
    name = "Monaco",
    size = 18,
    color = { white = 1, alpha = 0.8 },
}

local function drawPanel()
    if bgCanvas then
        bgCanvas:delete()
    end

    local screenFrame = hs.screen.mainScreen():frame()
    local width = 400
    local height = 100
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
    for k, _ in pairs(mediaKeys) do
        table.insert(keys, k)
    end
    table.sort(keys)

    local keyCount = #keys
    local buttonWidth = width / keyCount
    local buttonHeight = height

    for i, key in ipairs(keys) do
        local label = key
        if key == "comma" then label = "," end
        if key == "period" then label = "." end
        if key == "space" then label = "space" end
        if key == "left" then label = "←" end
        if key == "right" then label = "→" end

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
    local action = mediaKeys[key]
    if not action then return end
    local event = hs.eventtap.event.newSystemKeyEvent(action, true)
    event:post()
    local eventUp = hs.eventtap.event.newSystemKeyEvent(action, false)
    eventUp:post()
end

local function mediaHandler(event)
    local key = event:getCharacters(true)
    if mediaKeys[key] then
        triggerMedia(key)
        return true
    elseif key == "escape" then
        media_controller.stop()
        return true
    end
    return false
end

function media_controller.start()
    drawPanel()
    if eventtap then
        eventtap:stop()
        eventtap = nil
    end
    eventtap = hs.eventtap.new({hs.eventtap.event.types.keyDown}, mediaHandler)
    eventtap:start()
end

function media_controller.stop()
    if bgCanvas then
        bgCanvas:delete()
        bgCanvas = nil
    end
    if eventtap then
        eventtap:stop()
        eventtap = nil
    end
end

hs.hotkey.bind({"alt"}, "m", function()
    media_controller.start()
end)

return media_controller