local master_eventtap = require("master_eventtap")
local vim_mode = require("vim.vim_core")

local cursor_navigator = {}

-- depth
local currentDepth = 0
local maxDepth = 3
-- keys
local directionKeys = {"u","i","o",
                       "j",    "l",
                       "h","k",";"}
local goLastPointKeys = {"."}
-- canvas
local bgCanvas = nil
local gridCanvas = nil
local anchorCanvas = nil
local crossHairCanvas = nil
local screenFrame = {x = 0, y = 0, w = 0, h = 0}
local currentRect = {x = 0, y = 0, w = 0, h = 0}
-- vector2 pointer
local currentPointer = {x = 0, y = 0}
local lastClickedPointer = {x = 0, y = 0}
-- UI
local crossHair = {
    type = "crossHar",
    action = "fill",
    fillColor = { alpha = 0.3, red = 1, green = 1, blue = 0 },
    strokeColor = { alpha = 0.3, red = 1, green = 1, blue = 0 },
    strokeWidth = 0.5,
}
local font = {
    name = "Monaco",
    size = 16,
    normalColor = { alpha = 0.7, red = 1, green = 1, blue = 1 },
    underlayColor = { alpha = 0.4, red = 1, green = 1, blue = 0 },
}

local function drawBgPanel(rect)
    if bgCanvas then
        bgCanvas:delete()
    end

    bgCanvas = hs.canvas.new{
        x = rect.x,
        y = rect.y,
        w = rect.w,
        h = rect.h,
    }:show()

    bgCanvas:appendElements({
        type = "rectangle",
        action = "stroke",
        strokeColor = { alpha = 0.3, red = 0, green = 0, blue = 1 },
        strokeWidth = 0.5,
    })
end

local function drawGrid(rect)
    if gridCanvas then
        gridCanvas:delete()
    end

    gridCanvas = hs.canvas.new{
        x = rect.x,
        y = rect.y,
        w = rect.w,
        h = rect.h,
    }:show()

    gridCanvas:appendElements({
        type = "rectangle",
        action = "fill",
        fillColor = { alpha = 0.5, red = 0, green = 0, blue = 0 },
        strokeColor = { alpha = 0.5, red = 1, green = 1, blue = 1 },
        strokeWidth = 0.5,
    })

    local cellWidth, cellHeight = rect.w / 3, rect.h / 3

    for row = 0, 2 do
        for col = 0, 2 do
            local index = row * 3 + col + 1
            local label = directionKeys[index]
            gridCanvas:appendElements({
                {
                    type = "rectangle",
                    action = "stroke",
                    strokeColor = { alpha = 0.3, red = 1, green = 1, blue = 1 },
                    strokeWidth = 0.5,
                    frame = {
                        x = col * cellWidth,
                        y = row * cellHeight,
                        w = cellWidth,
                        h = cellHeight,
                    },
                },
                {
                    type = "text",
                    text = label,
                    textFont = font.name,
                    textSize = math.max(6, font.size - currentDepth * 2),
                    textColor = font.color,
                    frame = {
                        x = col * cellWidth + cellWidth / 2 - 6,
                        y = row * cellHeight + cellHeight / 2 - 12,
                        w = 20,
                        h = 24,
                    },
                }
            })
        end
    end
end

local function refineGrid(key)
    local index = hs.fnutils.indexOf(directionKeys, key)
    if not index then
        return
    end

    local row = math.floor((index - 1) / 3)
    local col = (index - 1) % 3

    local cellWidth, cellHeight = currentRect.w / 3, currentRect.h / 3
    currentRect = {
        x = currentRect.x + col * cellWidth,
        y = currentRect.y + row * cellHeight,
        w = cellWidth,
        h = cellHeight,
    }
    currentDepth = currentDepth + 1
    drawGrid(currentRect)
end

local function drawAnchor(rect)
    if anchorCanvas then
        anchorCanvas:delete()
    end

    anchorCanvas = hs.canvas.new{
        x = currentRect.x,
        y = currentRect.y,
        w = currentRect.w,
        h = currentRect.h,
    }:show()

    anchorCanvas:appendElements({
        type = "text",
        text = "",
        textFont = font.name,
        textSize = font.size,
        textColor = font.normalColor,
        frame = {
            x = rect.x + rect.w / 2 - 6,
            y = rect.y + rect.h / 2 - 12,
            w = 20,
            h = 24,
        },
        action = "fill",
        fillColor = font.underlayColor,
        strokeColor = font.underlayColor,
        strokeWidth = 0.5,
    })
end

local function drawCrossHair()
    if crossHairCanvas then
        crossHairCanvas:delete()
    end

    crossHairCanvas = hs.canvas.new{
        x = screenFrame.x,
        y = screenFrame.y,
        w = screenFrame.w,
        h = screenFrame.h,
    }:show()

    crossHairCanvas:appendElements(
        crossHair
    )
end

local function clickPointer(currentPointer)
    local point = currentPointer
    hs.mouse.absolutePosition(point)

    local clickDown = hs.eventtap.event.newMouseEvent(
        hs.eventtap.event.types.leftMouseDown, {
            x = point.x,
            y = point.y
        }
    )
    local clickUp = hs.eventtap.event.newMouseEvent(
        hs.eventtap.event.types.leftMouseUp, {
            x = point.x,
            y = point.y
        }
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
    if hs.fnutils.contains(directionKeys, key) then
        refineGrid(key)
        if currentDepth >= 3 then
            clickPointer()
            cursor_navigator.stop()
        end
        return true
    elseif key == " " then
        if currentDepth == 0 then
            clickPointer()
            cursor_navigator.stop()
        else
            clickPointer()
            cursor_navigator.stop()
        end
        return true
    end
    return false
end

function cursor_navigator.start()
    currentDepth = 0
    screenFrame = hs.screen.mainScreen():frame()
    currentPointer = {
        x = screenFrame.w / 2,
        y = screenFrame.h / 2,
    }
    currentRect = screenFrame
    drawBgPanel(currentRect)
    drawGrid(currentRect)
    drawAnchor(currentRect)
    drawCrossHair()

    master_eventtap.register(navigatorHandler)
end

function cursor_navigator.stop()
    if bgCanvas then
        bgCanvas:delete()
        bgCanvas = nil
    end
    if gridCanvas then
        gridCanvas:delete()
        gridCanvas = nil
    end
    if anchorCanvas then
        anchorCanvas:delete()
        anchorCanvas = nil
    end
    if crossHairCanvas then
        crossHairCanvas:delete()
        crossHairCanvas = nil
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