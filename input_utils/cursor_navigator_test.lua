local master_eventtap = require("master_eventtap")
local vim_mode = require("vim.vim_core")

local cursor_navigator = {}

local currentDepth = 0
local maxDepth = 3

local anchorCanvas = {}
-- keys ----------------------------------------------------------
-- eight anchors (see spec image):  ⬆︎D  ⬆︎I  ⬆︎F
--                                   J   ·   L
--                                 ⬇︎A  ⬇︎K  ⬇︎S
local anchorKeys = { "d", "i", "f",
                     "j",       "l",
                     "a", "k",  "s" }
-- key to jump to last‑clicked point
local lastPointKey = "."
-- arrow keys for micro‑adjustment in depth‑2
local microStepPx  = 2  -- expose for future tuning

-- grid divisions per depth (depth 0 → 4×4, depth 1 → 4×4, depth 2 → 2×2)
local GRID_DIVS = { 4, 4, 2 }

-- helper look‑up for arrow keyCodes
local KC = hs.keycodes.map  -- alias
local arrowKeyCodes = {
    [KC.up]    = {dx =  0, dy = -1},
    [KC.down]  = {dx =  0, dy =  1},
    [KC.left]  = {dx = -1, dy =  0},
    [KC.right] = {dx =  1, dy =  0},
}

-- canvas
local bgCanvas = nil
local gridCanvas = nil
local crossHairCanvas = nil
local screenFrame = {x = 0, y = 0, w = 0, h = 0}
local currentRect = {x = 0, y = 0, w = 0, h = 0}
-- vector2 pointer
local defaultPointer = {x = 0, y = 0}
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

local function drawBgPanel(gridRect)
    if bgCanvas then bgCanvas:delete() end

    -- depth‑0 remains fully transparent
    if currentDepth == 0 then
        bgCanvas = hs.canvas.new(screenFrame):show()
        return
    end

    bgCanvas = hs.canvas.new(screenFrame):show()
    -- darken whole screen
    bgCanvas:appendElements({
        type        = "rectangle",
        action      = "fill",
        fillColor   = {alpha = 0.55, red = 0, green = 0, blue = 0},
    })
    -- punch a transparent hole where the active grid lives
    bgCanvas:appendElements({
        type               = "rectangle",
        action             = "fill",
        compositeOperation = "destinationOut",
        fillColor          = {alpha = 1, red = 0, green = 0, blue = 0},
        frame              = {
                               x = gridRect.x,
                               y = gridRect.y,
                               w = gridRect.w,
                               h = gridRect.h,
                            },
    })
end

-- draw a grid made of <divs>×<divs> cells inside <rect>
-- internal lines are thinner; border lines thicker
local function drawGrid(rect, divs)
    if gridCanvas then
        gridCanvas:delete()
    end

    gridCanvas = hs.canvas.new(rect):show()

    -- draw background of grid area (transparent so that bgCanvas hole shows)
    gridCanvas:appendElements({
        type         = "rectangle",
        action       = "stroke",
        strokeColor  = {alpha = 0.6, red = 0, green = 1, blue = 1},
        strokeWidth  = 1.5,  -- border thickness
    })

    local cellW, cellH = rect.w / divs, rect.h / divs
    for r = 1, divs - 1 do
        -- horizontal inner lines
        gridCanvas:appendElements({
            type        = "rectangle",
            action      = "stroke",
            strokeColor = {alpha = 0.4, red = 0, green = 1, blue = 1},
            strokeWidth = 0.5,
            frame       = {x = 0, y = r * cellH, w = rect.w, h = 0},
        })
    end
    for c = 1, divs - 1 do
        -- vertical inner lines
        gridCanvas:appendElements({
            type        = "rectangle",
            action      = "stroke",
            strokeColor = {alpha = 0.4, red = 0, green = 1, blue = 1},
            strokeWidth = 0.5,
            frame       = {x = c * cellW, y = 0, w = 0, h = rect.h},
        })
    end
end

-- 8 anchor positions (row, col) in 4×4 space, skipping the centre block
local anchorCoords44 = {
    {1,1}, {1,2}, {1,3},
    {2,1},         {2,3},
    {3,1}, {3,2},  {3,3},
}

-- draw anchor labels and remember their absolute positions
local anchorMap = {}  -- key ➜ {x=,y=}
local function drawAnchors(rect)
    if anchorCanvas then anchorCanvas:delete() end
    anchorCanvas = hs.canvas.new(rect):show()

    anchorMap = {}
    local cellW, cellH = rect.w / 4, rect.h / 4

    for i, rc in ipairs(anchorCoords44) do
        local r, c = table.unpack(rc)
        local frame = {
            x = (c-1) * cellW,
            y = (r-1) * cellH,
            w = cellW,
            h = cellH,
        }
        local label = anchorKeys[i]

        -- label background (yellow)
        anchorCanvas:appendElements({
            type        = "rectangle",
            action      = "fill",
            fillColor   = {alpha = 0.8, red = 1, green = 1, blue = 0},
            frame       = {
                            x = frame.x + cellW*0.4,
                            y = frame.y + cellH*0.4,
                            w = cellW*0.2,
                            h = cellH*0.2,
                         },
        })
        -- label text (black)
        anchorCanvas:appendElements({
            type       = "text",
            text       = label:upper(),
            textFont   = font.name,
            textSize   = font.size,
            textColor  = {alpha = 1, red = 0, green = 0, blue = 0},
            frame      = {
                            x = frame.x + cellW*0.4,
                            y = frame.y + cellH*0.35,
                            w = cellW*0.2,
                            h = cellH*0.3,
                         },
        })

        -- save centre of the anchor for quick lookup
        anchorMap[label] = {
            x = rect.x + frame.x + cellW * 0.5,
            y = rect.y + frame.y + cellH * 0.5,
        }
    end
end

local function drawCrossHair()
    if crossHairCanvas then crossHairCanvas:delete() end
    crossHairCanvas = hs.canvas.new{
        x = screenFrame.x,
        y = screenFrame.y,
        w = screenFrame.w,
        h = screenFrame.h,
    }:show()

    crossHairCanvas:appendElements({
        -- vertical line
        {
            type        = "rectangle",
            action      = "fill",
            fillColor   = {alpha = 0.3, red = 1, green = 1, blue = 0},
            frame       = {x = currentPointer.x - 0.25, y = 0,
                           w = 0.5, h = screenFrame.h},
        },
        -- horizontal line
        {
            type        = "rectangle",
            action      = "fill",
            fillColor   = {alpha = 0.3, red = 1, green = 1, blue = 0},
            frame       = {x = 0, y = currentPointer.y - 0.25,
                           w = screenFrame.w, h = 0.5},
        },
        -- small centre mark
        {
            type        = "circle",
            action      = "stroke",
            strokeColor = {alpha = 0.6, red = 1, green = 1, blue = 0},
            strokeWidth = 1,
            frame       = {x = currentPointer.x - 4, y = currentPointer.y - 4,
                           w = 8, h = 8},
        },
    })
end

-- animate crosshair towards new point (simple linear tween)
local function moveCrossHair(toPoint)
    local steps, interval = 6, 0.015
    local fromX, fromY = currentPointer.x, currentPointer.y
    local dX = (toPoint.x - fromX) / steps
    local dY = (toPoint.y - fromY) / steps

    local i = 0
    hs.timer.doUntil(
        function() return i >= steps end,
        function()
            i = i + 1
            currentPointer.x = fromX + dX * i
            currentPointer.y = fromY + dY * i
            drawCrossHair()  -- redraw at intermediate spot
        end,
        interval
    )
end

local function clickPointer()
    local center = nil
    if currentDepth == 0 then
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
    hs.mouse.absolutePosition(center)
    local clickDown = hs.eventtap.event.newMouseEvent(
        hs.eventtap.event.types.leftMouseDown,
        {x = center.x, y = center.y}
    )
    local clickUp = hs.eventtap.event.newMouseEvent(
        hs.eventtap.event.types.leftMouseUp,
        {x = center.x, y = center.y}
    )

    -- record last clicked position for next session
    lastClickedPointer = {x = center.x, y = center.y}

    clickDown:post()
    hs.timer.usleep(20000) -- 20ms delay
    clickUp:post()
end

local function refineGrid(key)
    local idx = hs.fnutils.indexOf(anchorKeys, key)
    if not idx then return end

    local r, c = table.unpack(anchorCoords44[idx])

    -- find new rect based on current depth
    local divsNow = GRID_DIVS[currentDepth + 1]
    local cellW   = currentRect.w / 4     -- anchor always references 4×4 grid
    local cellH   = currentRect.h / 4

    -- area is 1×1 (depth1) or 1×1 (depth2) by default
    local newRect = {
        x = currentRect.x + (c-1) * cellW,
        y = currentRect.y + (r-1) * cellH,
        w = cellW,
        h = cellH,
    }

    -- for the first zoom we enlarge to a 2×2 block for easier view
    if currentDepth == 0 then
        if c < 4 then newRect.w = cellW * 2 end
        if r < 4 then newRect.h = cellH * 2 end
    end

    -- update depth & currentRect
    currentDepth  = currentDepth + 1
    currentRect   = newRect

    -- move pointer first (animated)
    local p = { x = newRect.x + newRect.w/2, y = newRect.y + newRect.h/2 }
    moveCrossHair(p)

    -- depth2 immediately triggers click
    if currentDepth >= 3 then
        clickPointer()
        cursor_navigator.stop()
        return
    end

    -- redraw everything for next depth
    drawBgPanel(currentRect)
    drawGrid(currentRect, GRID_DIVS[currentDepth + 1])
    drawAnchors(currentRect)
end

local function navigatorHandler(event)
    local keyStr  = event:getCharacters(true) or ""
    local keyCode = event:getKeyCode()

    -- escape: quit without clicking
    if keyStr == "escape" then
        cursor_navigator.stop()
        return true
    end

    -- jump to previous point and click
    if keyStr == lastPointKey and lastClickedPointer.x then
        moveCrossHair(lastClickedPointer)
        hs.timer.doAfter(0.11, function()
            clickPointer()
            cursor_navigator.stop()
        end)
        return true
    end

    -- micro adjust when in depth‑2
    if currentDepth == 2 and arrowKeyCodes[keyCode] then
        local delta = arrowKeyCodes[keyCode]
        currentRect.x = currentRect.x + delta.dx * microStepPx
        currentRect.y = currentRect.y + delta.dy * microStepPx
        moveCrossHair({x = currentRect.x + currentRect.w/2,
                       y = currentRect.y + currentRect.h/2})
        drawBgPanel(currentRect)
        drawGrid(currentRect, GRID_DIVS[3])   -- still 2×2
        drawAnchors(currentRect)
        return true
    end

    -- anchor selection
    if hs.fnutils.indexOf(anchorKeys, keyStr) then
        refineGrid(keyStr)
        return true
    end

    -- space triggers click at current pointer
    if keyStr == " " then
        clickPointer()
        cursor_navigator.stop()
        return true
    end

    return false
end

function cursor_navigator.start()
    currentDepth = 0
    screenFrame = hs.screen.mainScreen():frame()
    defaultPointer = {
        x = screenFrame.w / 2,
        y = screenFrame.h / 2,
    }
    currentRect = screenFrame

    currentPointer = {
        x = defaultPointer.x,
        y = defaultPointer.y,
    }
    drawBgPanel(screenFrame)  -- transparent at depth‑0
    drawGrid(currentRect, GRID_DIVS[1])
    drawAnchors(currentRect)
    drawCrossHair()

    -- show 'previous click' anchor if we have one
    if lastClickedPointer.x then
        anchorCanvas:appendElements({
            type       = "text",
            text       = "•",
            textFont   = font.name,
            textSize   = font.size + 4,
            textColor  = {alpha = 1, red = 1, green = 0, blue = 0},
            frame      = {x = lastClickedPointer.x - 4,

                          y = lastClickedPointer.y - 8,
                          w = 16, h = 16},
        })
    end

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