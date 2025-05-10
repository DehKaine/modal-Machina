local Style = require("input_utils.cursor_navigator.canvas_style")
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

local function generateGridPoints(focusArea)
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

--------------------------------------------------------------------
-- buildGridElements : returns segments & border elements
--------------------------------------------------------------------
local function buildGridElements(frame, rows, cols, innerWidth)
    rows       = rows or 4
    cols       = cols or 4
    innerWidth = innerWidth or 1
    local lineColor   = Style.grid.strokeColor
    local borderColor = Style.grid.strokeColor
    local borderW     = innerWidth

    local elements = {}
    local cellW, cellH = frame.w / cols, frame.h / rows

    -- vertical lines
    for c = 1, cols-1 do
        local x = c * cellW
        table.insert(elements, {
            type="segments", action="stroke",
            strokeWidth = innerWidth,
            strokeColor = lineColor,
            coordinates = { {x=x, y=0}, {x=x, y=frame.h} },
        })
    end
    -- horizontal lines
    for r = 1, rows-1 do
        local y = r * cellH
        table.insert(elements, {
            type="segments", action="stroke",
            strokeWidth = innerWidth,
            strokeColor = lineColor,
            coordinates = { {x=0, y=y}, {x=frame.w, y=y} },
        })
    end
    -- border
    table.insert(elements, {
        type="rectangle", action="stroke",
        strokeWidth = borderW,
        strokeColor = borderColor,
        frame = {x=0, y=0, w=frame.w, h=frame.h},
    })
    return elements
end

local function drawAnchors(gridPoints)
    local anchorItems = {}
    for _, anchor in ipairs(anchorsMap) do
        local point = gridPoints[anchor.r][anchor.c]
        local label = anchor.key
        --
        local underlaySize = Style.anchor.fontSize + Style.anchor.padding * 2
        local underlayRect = hs.geometry.rect(
            point.x - underlaySize/2,
            point.y - underlaySize/2,
            underlaySize,
            underlaySize
        )
        local underlay = hs.drawing.rectangle(underlayRect)
        underlay:setFillColor(Style.anchor.underlayColor)
                :setStroke(false)
                :setRoundedRectRadii(Style.anchor.radius, Style.anchor.radius)
                -- :bringToFront(true)
                :show()
        --
        local text = hs.drawing.text(underlayRect, label)
        text:setTextFont(Style.anchor.fontName)
            :setTextSize(Style.anchor.fontSize)
            :setTextColor(Style.anchor.normalColor)
            :setTextAlignment("center")
            -- :bringToFront(true)
            :show()
        --
        table.insert(anchorItems, underlay)
        table.insert(anchorItems, text)
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
    local gridEls = buildGridElements({x=0,y=0,w=frame.w,h=frame.h}, rows, cols, innerWidth)
    self.grid:appendElements(gridEls)

    -- 2. generate anchors & append
    local gridPoints = generateGridPoints(frame)

    local anchorEls = {}
    local bgColor   = Style.anchor.underlayColor
    local textColor = Style.anchor.normalColor
    local fontName  = Style.anchor.fontName
    local fontSize  = Style.anchor.fontSize
    local radius    = Style.anchor.radius
    local pad       = Style.anchor.padding
    local boxSize   = fontSize + pad*2

    for _,a in ipairs(anchorsMap) do
        local pt   = gridPoints[a.r][a.c]
        local rect = {x = pt.x - boxSize/2 - frame.x,  -- local coords
                      y = pt.y - boxSize/2 - frame.y,
                      w = boxSize, h = boxSize}

        table.insert(anchorEls, {
            type="rectangle", action="fill",
            fillColor = bgColor,
            roundedRectRadii = {xRadius=radius, yRadius=radius},
            frame = rect,
        })
        table.insert(anchorEls, {
            type="text",
            text=a.key,
            textFont = fontName,
            textSize = fontSize,
            textColor = textColor,
            textAlignment="center",
            frame = rect,
        })
    end
    self.grid:appendElements(anchorEls)
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