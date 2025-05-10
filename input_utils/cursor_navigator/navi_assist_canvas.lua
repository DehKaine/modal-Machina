local Style = require("input_utils.cursor_navigator.cursor_navi_styles")
local Mask = require("ui.overlay_mask")
--
local NaviCanvas = {}
NaviCanvas.__index = NaviCanvas

function NaviCanvas:new()
    local self = setmetatable({}, NaviCanvas)
    self.mask = nil
    self.grid = nil
    self.anchor = nil
    return self
end

local anchorsMap = {
    {r = 2, c = 2, key = "u"}, {r = 2, c = 3, key = "i"}, {r = 2, c = 4, key = "o"},
    {r = 3, c = 2, key = "j"},                            {r = 3, c = 4, key = "l"},
    {r = 4, c = 2, key = "h"}, {r = 4, c = 3, key = "k"}, {r = 4, c = 4, key = "_"},
}

function NaviCanvas:generateGridPoints(focusArea)
    local points = {}
    local stepX = focusArea.w / 4
    local stepY = focusArea.h / 4
    for r = 1, 5 do
        points[r] = {}
        for c = 1, 5 do
            points[r][c] = {
                x = focusArea.x + (c-1) * stepX,
                y = focusArea.y + (r-1) * stepY,
            }
        end
    end
    return points
end

function NaviCanvas:getNewFocusArea(oldFrame, centerPoint)
    local newFocusArea = {}
    --
    local newW = oldFrame.w / 2
    local newH = oldFrame.h / 2
    local newX = centerPoint.x - newW / 2
    local newY = centerPoint.y - newH / 2
    --
    local newFocusArea = {
        x = newX, y = newY, w = newW, h = newH
    }
    return newFocusArea
end

local function drawGrid(frame, rows, cols, innerWidth)
    rows = rows or 4
    cols = cols or 4
    innerWidth = innerWidth or Style.grid.lineWidth
    local innerLineColor = Style.grid.innerLineColor
    local outLineColor   = Style.grid.outLineColor
    local outLineWidth   = Style.grid.lineWidth

    local elements = {}
    local cellW, cellH = frame.w / cols, frame.h / rows

    -- vertical lines
    for c = 1, cols-1 do
        local x = c * cellW
        table.insert(elements, {
            type = "segments",
            action = "stroke",
            strokeWidth = innerWidth,
            strokeColor = innerLineColor,
            coordinates = { {x=x, y=0}, {x=x, y=frame.h} },
        })
    end
    -- horizontal lines
    for r = 1, rows-1 do
        local y = r * cellH
        table.insert(elements, {
            type = "segments",
            action = "stroke",
            strokeWidth = innerWidth,
            strokeColor = innerLineColor,
            coordinates = { {x=0, y=y}, {x=frame.w, y=y} },
        })
    end
    -- focus area outline
    table.insert(elements, {
        type = "rectangle",
        action = "stroke",
        strokeWidth = outLineWidth,
        strokeColor = outLineColor,
        frame = {x=0, y=0, w=frame.w, h=frame.h},
    })
    return elements
end

local function drawAnchors(gridPoints,frame)
    local anchorItems = {}
    local bgColor   = Style.anchor.underlayColor
    local textColor = Style.anchor.normalColor
    local fontName  = Style.anchor.fontName
    local fontSize  = Style.anchor.fontSize
    local radius    = Style.anchor.radius
    local padding   = Style.anchor.padding
    local bgSize   = fontSize + padding * 2

    for _,anchor in ipairs(anchorsMap) do
        local point   = gridPoints[anchor.r][anchor.c]
        local rect = {x = point.x - bgSize/2 - frame.x,
                      y = point.y - bgSize/2 - frame.y + 2,
                      w = bgSize, h = bgSize}
        table.insert(anchorItems, {
            type = "rectangle",
            action = "fill",
            fillColor = bgColor,
            roundedRectRadii = {xRadius=radius, yRadius=radius},
            frame = rect,
        })
        table.insert(anchorItems, {
            type = "text",
            text = anchor.key,
            textFont = fontName,
            textSize = fontSize,
            textColor = textColor,
            textAlignment = "center",
            frame = rect,
        })
    end
    return anchorItems
end

function NaviCanvas:drawAssistCanvas(frame, rows, cols, innerWidth)
    frame = frame or hs.screen.mainScreen():fullFrame()
    rows = rows or 4
    cols = cols or 4
    innerWidth = innerWidth or 1
    --
    if self.grid then self.grid:delete() end
    self.grid = hs.canvas.new(frame):show()
    --
    local gridCells = drawGrid({x=0,y=0,w=frame.w,h=frame.h}, rows, cols, innerWidth)
    self.grid:appendElements(gridCells)
    --
    local gridPoints = NaviCanvas:generateGridPoints(frame)
    local anchorItems = drawAnchors(gridPoints, frame)
    self.grid:appendElements(anchorItems)
end

function NaviCanvas:drawMask()
    if self.mask then self.mask:destroy() end
    self.mask = Mask:new()
    self.mask:show()
end

function NaviCanvas:refineMask(focusArea)
    if self.mask then
        self.mask:focusTo(focusArea)
    end
end

function NaviCanvas:destroy()
    if self.mask then self.mask:destroy() self.mask = nil end
    if self.grid then self.grid:delete() self.grid = nil end
    if self.anchor then self.anchor:delete() self.anchor = nil end
end

return NaviCanvas