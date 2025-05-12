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
local maxDepth = 4
-- keys
local directionKeys = {"u","i","o",
                       "j",    "l",
                       "h","k","_"}
local keyToAnchorMap = {
    u = {r = 2, c = 2}, i = {r = 2, c = 3}, o = {r = 2, c = 4},
    j = {r = 3, c = 2},                     l = {r = 3, c = 4},
    h = {r = 4, c = 2}, k = {r = 4, c = 3}, ["_"] = {r = 4, c = 4}
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

local function clickPointer(currentPointer)
    local point = currentPointer
    hs.mouse.absolutePosition(point)

    local clickDown = hs.eventtap.event.newMouseEvent(
        hs.eventtap.event.types.leftMouseDown, { x = point.x, y = point.y }
    )
    local clickUp = hs.eventtap.event.newMouseEvent(
        hs.eventtap.event.types.leftMouseUp, { x = point.x, y = point.y }
    )
    clickDown:post()
    hs.timer.usleep(20000)
    clickUp:post()
    lastClickedPointer = point
end

local function handleAnchorKey(key)
    local anchorIndex = keyToAnchorMap[key] 
    if not anchorIndex then return end
    --
    local gridPoints = naviCanvas:generateGridPoints(currentRect)
    local targetPointer = gridPoints[anchorIndex.r][anchorIndex.c]
    --
    local startPointer = currentPointer
    hs.mouse.absolutePosition(targetPointer)
    Tween.move(startPointer, targetPointer, 0.2, function (pos) 
        crosshair:moveTo(pos.x, pos.y)
    end)
    --
    local newFocusArea = naviCanvas:getNewFocusArea(currentRect, targetPointer)
    naviCanvas:refineMask(newFocusArea)
    naviCanvas:drawAssistCanvas(newFocusArea,currentDepth)
    --
    currentPointer = targetPointer
    currentRect = newFocusArea
    currentDepth = currentDepth + 1
    if currentDepth >= maxDepth then
        clickPointer(currentPointer)
        modal:exit()
    end
end

local function navigatorHandler(event)
    local key = event:getCharacters(true)
    if hs.fnutils.contains(directionKeys, key) then
        handleAnchorKey(key)
        return true
    end
    return false
    end

local function init_navigator()
    currentDepth = 0
    screenFrame = hs.screen.mainScreen():fullFrame()
    currentPointer = {
        x = screenFrame.x + screenFrame.w / 2,
        y = screenFrame.y + screenFrame.h / 2,
    }
    currentRect = screenFrame
    crosshair:show(currentRect)
    naviCanvas:drawMask(nil,screenFrame)
    naviCanvas:drawAssistCanvas()
end

function modal:entered()
    if vim_mode then
        vim_mode.exitVim()
    end
    init_navigator()
    master_eventtap.register(navigatorHandler)
end

modal:bind({}, ".", function()
    clickPointer(lastClickedPointer)
    modal:exit()
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