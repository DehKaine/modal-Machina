local master_eventtap = require("master_eventtap")
local vim_mode = require("vim.vim_core")
local Tween = require("animation.tween")
--
local Crosshair = require("input_utils.cursor_navigator.crosshair")
local NaviCanvas = require("input_utils.cursor_navigator.navi_assist_canvas")
--
local cursor_navigator = {}
local modal = hs.hotkey.modal.new({"alt"}, "c")

-- depth
local currentDepth = 0
local maxDepth = 3
-- keys
local directionKeys = {"u","i","o",
                       "j",    "l",
                       "h","k",";"}
local goLastPointKeys = {"."}
local keyToAnchorMap = {
    u = {r = 2, c = 2}, i = {r = 2, c = 3}, o = {r = 2, c = 4},
    j = {r = 3, c = 2},                     l = {r = 3, c = 4},
    h = {r = 4, c = 2}, k = {r = 4, c = 3}, [";"] = {r = 4, c = 4}
}
-- screen & canvas
local screenFrame = {x = 0, y = 0, w = 0, h = 0}
local currentRect = {x = 0, y = 0, w = 0, h = 0}
-- vector2 pointer
local currentPointer = {x = 0, y = 0}
local lastClickedPointer = {x = 0, y = 0}
-- UI
local crosshair = Crosshair:new()
local naviCanvas = NaviCanvas:new()

local function drawBgPanel(rect)
    local bgCanvas
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
end

local function drawAnchor(rect)
    local anchorCanvas
    if anchorCanvas then
        anchorCanvas:delete()
    end
    local font = {}
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
    lastClickedPointer = point
end

local function navigatorHandler(event)
    -- local key = event:getCharacters(true)
    -- if hs.fnutils.contains(directionKeys, key) then
    --     refineGrid(key)
    --     if currentDepth >= 3 then
    --         clickPointer()
    --         cursor_navigator.stop()
    --     end
    --     return true
    -- elseif key == " " then
    --     if currentDepth == 0 then
    --         clickPointer()
    --         cursor_navigator.stop()
    --     else
    --         clickPointer()
    --         cursor_navigator.stop()
    --     end
    --     return true
    -- end
    -- return false
end

local function init_navigator()
    currentDepth = 0
    screenFrame = hs.screen.mainScreen():fullFrame()
    currentPointer = {
        x = screenFrame.w / 2,
        y = screenFrame.h / 2,
    }
    currentRect = screenFrame
    naviCanvas:drawMask()
    naviCanvas:drawAssistCanvas()
    crosshair:show(currentRect)
end

function modal:entered()
    if vim_mode then
        vim_mode.exitVim()
    end
    init_navigator()
    master_eventtap.register(navigatorHandler)
end

modal:bind({}, "k", function()
    local targetPointer = {
        x = currentPointer.x + 100,
        y = currentPointer.y + 100
    }
    local startPointer = currentPointer
    Tween.move(startPointer, targetPointer, 0.2, function(pos)
        crosshair:moveTo(pos.x, pos.y)
    end)
    currentPointer = targetPointer
    naviCanvas:refineMask({x=0,y=0,w=400,h=300})
    naviCanvas:drawAssistCanvas({x=0,y=0,w=400,h=300})
end)

function modal:exited()
    crosshair:destroy()
    naviCanvas:destroy()
    master_eventtap.unregister(navigatorHandler)
end

modal:bind({},"space", function()
    clickPointer(currentPointer)
    modal:exit()
end)

modal:bind({},"escape", function()
    modal:exit()
end)

return cursor_navigator