local master_eventtap = require("master_eventtap")
local vim_mode = require("vim_mode")

local cursor_navigator = {}

local currentLevel = 0

local canvas = nil
local currentRect = {x = 0, y = 0, w = 0, h = 0}
local gridKeys = {"u","i", "o", "j", "k", "l", "m", ",", "."}
local screenFrame = nil
local font = {
    name = "Monaco",
    size = 16,
    color = #{hex="#FFFFF"},
}

local function drawGrid(rect)
    if canvas then
        canvas:delete()
    end

    canvas = hs.canvas.new{
        x = rect.x,
        y = rect.y,
        w = rect.w,
        h = rect.h,
    }:show()

    canvas:appendElements({
        type = "rectangle",
        action = "fill",
        fillColor = { alpha = 0.5, red = 0, green = 0, blue = 0 },
        strokeColor = { alpha = 0.5, red = 1, green = 1, blue = 1 },
        strokeWidth = 0.5,
    })

    local w3, h3 = rect.w / 3, rect.h / 3

    for row = 0, 2 do
        for col = 0, 2 do
            local index = row * 3 + col + 1
            local label = gridKeys[index]
            canvas:appendElements({
                {
                    type = "rectangle",
                    action = "stroke",
                    strokeColor = { alpha = 0.3, red = 1, green = 1, blue = 1 },
                    strokeWidth = 0.5,
                    frame = {
                        x = col * w3,
                        y = row * h3,
                        w = w3,
                        h = h3,
                    },
                },
                {
                    type = "text",
                    text = label,
                    textFont = font.name,
                    textSize = math.max(6, font.size - currentLevel * 2),
                    textColor = font.color,
                    frame = {
                        x = col * w3 + w3 / 2 - 6,
                        y = row * h3 + h3 / 2 - 12,
                        w = 20,
                        h = 24,
                    },
                }
            })
        end
    end
end

local function refineGrid(key)
    local index = hs.fnutils.indexOf(gridKeys, key)
    if not index then
        return
    end

    local row = math.floor((index - 1) / 3)
    local col = (index - 1) % 3

    local w3, h3 = currentRect.w / 3, currentRect.h / 3
    currentRect = {
        x = currentRect.x + col * w3,
        y = currentRect.y + row * h3,
        w = w3,
        h = h3,
    }
    currentLevel = currentLevel + 1
    drawGrid(currentRect)
end

local function clickCenter()
    local center = nil
    if currentLevel == 0 then
        local screenFrame = hs.screen.mainScreen():frame()
        center = {
            x = screenFrame.x + screenFrame.w / 2,
            y = screenFrame.y + screenFrame.h / 2,
        }
    else
        center = {
            x = currentRect.x + currentRect.w / 2,
            y = currentRect.y + currentRect.h / 2,
        }
    end
    -- hs.eventtap.leftClick(center)
    hs.mouse.setAbsolutePosition(center)
    local clickDown = hs.eventtap.event.newMouseEvent(
        hs.eventtap.event.types.leftMouseDown,
        {x = center.x, y = center.y}
    )
    local clickUp = hs.eventtap.event.newMouseEvent(
        hs.eventtap.event.types.leftMouseUp,
        {x = center.x, y = center.y}
    )

    clickDown:post()
    hs.timer.usleep(20000) -- 20ms delay
    clickUp:post()
end

local function navigatorHandler(event)
    local key = event:getCharacters(true)
    if key == "escape" then
        cursor_navigator.stop()
        return true
    end
    if hs.fnutils.contains(gridKeys, key) then
        refineGrid(key)
        if currentLevel >= 3 then
            clickCenter()
            cursor_navigator.stop()
        end
        return true
    elseif key == " " then
        if currentLevel == 0 then
            clickCenter()
            cursor_navigator.stop()
        else
            clickCenter()
            cursor_navigator.stop()
        end
        return true
    end
    return false
end

function cursor_navigator.start()
    currentLevel = 0
    screenFrame = hs.screen.mainScreen():frame()
    currentRect = screenFrame
    drawGrid(currentRect)

    master_eventtap.register(navigatorHandler)
end

function cursor_navigator.stop()
    if canvas then
        canvas:delete()
        canvas = nil
    end
    master_eventtap.unregister(navigatorHandler)
end

hs.hotkey.bind({"alt"}, "c", function()
    if vim_mode then
        vim_mode.exitVim()
    end
    cursor_navigator.start()
end)

return cursor_navigator