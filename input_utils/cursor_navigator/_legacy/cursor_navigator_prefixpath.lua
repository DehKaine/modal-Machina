local master_eventtap = require("master_eventtap")
local vim_mode = require("vim.vim_core")

local cursor_navigator = {}

local currentLevel = 0
local maxLevel = 3

-- local gridKeys = {"u","i","o","j","k","l","m",",","."}
local gridKeys = {"a","s","d","f","g","h","j","k","l"}
local prefixPath = ""
local highlightId = nil

local bgCanvas = nil
local gridCanvas = nil
local currentRect = {x = 0, y = 0, w = 0, h = 0}
local textCanvas = nil      -- new canvas dedicated to instruction text
local drawInstructions      -- forward declaration
local screenFrame = {}
local font = {
    name = "Monaco",
    size = 16,
    normalColor = { alpha = 0.4, red = 1, green = 1, blue = 1 },
    highlightColor = { alpha = 1, red = 1, green = 1, blue = 0 },
    color = { alpha = 1, red = 1, green = 1, blue = 1 },
}

-- local subGrids = {}

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
        action = "fill",
        fillColor = { alpha = 0.3, red = 0, green = 0, blue = 0 }
    })
end

local function drawGrid(rect)
    -- delete existing canvas
    if gridCanvas then
        gridCanvas:delete()
    end
    gridCanvas = hs.canvas.new{
        x = rect.x,
        y = rect.y,
        w = rect.w,
        h = rect.h,
    }:show()

    -- draw outer border
    gridCanvas:appendElements({
        {
            type = "rectangle",
            action = "stroke",
            frame = { x = 0, y = 0, w = rect.w, h = rect.h },
            strokeColor = { alpha = 0.5, red = 1, green = 1, blue = 1 },
            strokeWidth = 0.5,
        },
    })

    local function drawLayer(level, baseRect, path)
        local w = baseRect.w / 3
        local h = baseRect.h / 3
        for row = 0, 2 do
            for col = 0, 2 do
                local idx = row * 3 + col + 1
                local key = gridKeys[idx]
                local cellRect = {
                    x = baseRect.x + col * w,
                    y = baseRect.y + row * h,
                    w = w,
                    h = h,
                }
                -- draw cell border with varying opacity per level
                gridCanvas:appendElements({
                    {
                        type = "rectangle",
                        action = "stroke",
                        strokeColor = { alpha = 0.3 - 0.1 * level, red = 1, green = 1, blue = 1 },
                        strokeWidth = 0.5,
                        frame = cellRect,
                    },
                })
                local code = path .. key
                -- draw deeper layers if any remain
                if level < maxLevel - 1 then
                    drawLayer(level + 1, cellRect, code)
                end
            end
        end
    end

    -- start drawing from current level and prefix using coordinates relative to the canvas
    local baseRect = { x = 0, y = 0, w = rect.w, h = rect.h }
    drawLayer(currentLevel, baseRect, prefixPath)

    -- after drawing the grid lines, draw the instruction labels
    drawInstructions(rect)
end

-- draw 3‑character instruction codes in a separate canvas
function drawInstructions(rect)
    if textCanvas then
        textCanvas:delete()
    end
    textCanvas = hs.canvas.new{
        x = rect.x,
        y = rect.y,
        w = rect.w,
        h = rect.h,
    }:show()

    local remaining = maxLevel - currentLevel          -- how many layers we still have to subdivide
    local sizeTable  = { [3] = 10, [2] = 14, [1] = 16 } -- slightly larger sizes for visibility
    local charSize   = sizeTable[remaining] or 10
    local charW      = charSize                         -- assume roughly square glyphs for safety

    -- recursive helper to descend to the smallest cells that will show a code
    local function recurse(depth, baseRect, codePath)
        if depth == 0 then
            local prefixLen = #prefixPath
            local suffix    = codePath:sub(prefixLen + 1)

            local totalW = charW * 3     -- full width for 3‑char code
            local xStart = baseRect.x + baseRect.w / 2 - totalW / 2
            local yStart = baseRect.y + baseRect.h / 2 - charSize / 2

            -- dimmed prefix (if any)
            if prefixLen > 0 then
                textCanvas:appendElements({
                    {
                        type      = "text",
                        text      = prefixPath,
                        textFont  = font.name,
                        textSize  = charSize,
                        textColor = { alpha = 0.4, red = 1, green = 1, blue = 1 },
                        frame     = {
                            x = xStart,
                            y = yStart,
                            w = charW * prefixLen * 1.1,
                            h = charSize * 1.2,
                        },
                    }
                })
            end

            -- highlighted / normal suffix
            textCanvas:appendElements({
                {
                    type      = "text",
                    text      = suffix,
                    textFont  = font.name,
                    textSize  = charSize,
                    textColor = (prefixLen > 0) and font.highlightColor or font.normalColor,
                    frame     = {
                        x = xStart + charW * prefixLen,
                        y = yStart,
                        w = charW * (3 - prefixLen) * 1.1,
                        h = charSize * 1.2,
                    },
                }
            })
            return
        end

        local w, h = baseRect.w / 3, baseRect.h / 3
        for row = 0, 2 do
            for col = 0, 2 do
                local idx = row * 3 + col + 1
                local key = gridKeys[idx]
                recurse(
                    depth - 1,
                    {
                        x = baseRect.x + col * w,
                        y = baseRect.y + row * h,
                        w = w,
                        h = h,
                    },
                    codePath .. key
                )
            end
        end
    end

    -- start with coordinates relative to the textCanvas origin (0,0)
    local localRect = { x = 0, y = 0, w = rect.w, h = rect.h }
    recurse(remaining, localRect, prefixPath)
end

local function refineGrid(key)
    -- for _, canvas in pairs(subGrids) do
    --     canvas:delete()
    -- end
    -- subGrids = {}

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
    prefixPath = prefixPath .. key
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
        if currentLevel >= maxLevel then
            print("Max Level Reached")
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
    prefixPath = ""
    screenFrame = hs.screen.mainScreen():frame()
    currentRect = screenFrame
    drawBgPanel(currentRect)
    drawGrid(currentRect)

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
    if textCanvas then
        textCanvas:delete()
        textCanvas = nil
    end
    -- for _, canvas in pairs(subGrids) do
    --     canvas:delete()
    -- end
    -- subGrids = {}
    currentLevel = 0
    prefixPath = ""
    master_eventtap.unregister(navigatorHandler)
end

hs.hotkey.bind({"alt"}, "c", function()
    if vim_mode then
        vim_mode.exitVim()
    end
    cursor_navigator.start()
end)

return cursor_navigator