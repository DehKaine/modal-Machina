local master_eventtap = require("master_eventtap")
local vim_mode = require("vim_mode")

local cursor_navigator = {}

local currentLevel = 0
local maxLevel = 3

local gridKeys = {"u","i","o","j","k","l","m",",","."}
local prefixPath = ""
local highlightId = nil

local bgCanvas = nil
local gridCanvas = nil
local currentRect = {x = 0, y = 0, w = 0, h = 0}
local screenFrame = {}
local font = {
    name = "Monaco",
    size = 16,
    normalColor = { hex="#FFFFF" },
    highlightColor = { alpha = 1, red = 1, green = 1, blue = 0 },
    color = { alpha = 1, red = 1, green = 1, blue = 1 },
}

local subGrids = {}

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
    -- helper table that keeps track of which codes have already been rendered
    local seenCodes = {}
    -- draw the code only if none of its shorter prefixes have been rendered
    local function should_draw(code)
        for i = 1, #code - 1 do
            if seenCodes[code:sub(1, i)] then
                return false
            end
        end
        return true
    end

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
        action = "stroke",
        strokeColor = { alpha = 0.5, red = 1, green = 1, blue = 1 },
        strokeWidth = 0.5,
    })

    local w3, h3 = rect.w / 3, rect.h / 3

    if currentLevel == 0 then
        -- Draw level 0 grid with labels
        for row = 0, 2 do
            for col = 0, 2 do
                local index = row * 3 + col + 1
                local k0 = gridKeys[index]
                local frame0 = {
                    x = col * w3,
                    y = row * h3,
                    w = w3,
                    h = h3,
                }
                -- Draw level 0 cell border
                gridCanvas:appendElements({
                    {
                        type = "rectangle",
                        action = "stroke",
                        strokeColor = { alpha = 0.3, red = 1, green = 1, blue = 1 },
                        strokeWidth = 0.5,
                        frame = frame0,
                    },
                })
                -- Draw level 1 and level 2 sub grids inside this cell
                local w9, h9 = w3 / 3, h3 / 3
                for subRow = 0, 2 do
                    for subCol = 0, 2 do
                        local index1 = subRow * 3 + subCol + 1
                        local k1 = gridKeys[index1]
                        local frame1 = {
                            x = frame0.x + subCol * w9,
                            y = frame0.y + subRow * h9,
                            w = w9,
                            h = h9,
                        }
                        -- Draw level 1 cell border
                        gridCanvas:appendElements({
                            {
                                type = "rectangle",
                                action = "stroke",
                                strokeColor = { alpha = 0.15, red = 1, green = 1, blue = 1 },
                                strokeWidth = 0.5,
                                frame = frame1,
                            },
                        })
                        for subSubRow = 0, 2 do
                            for subSubCol = 0, 2 do
                                local index2 = subSubRow * 3 + subSubCol + 1
                                local k2 = gridKeys[index2]
                                local frame2 = {
                                    x = frame1.x + subSubCol * (w9 / 3),
                                    y = frame1.y + subSubRow * (h9 / 3),
                                    w = w9 / 3,
                                    h = h9 / 3,
                                }
                                -- Draw level 2 cell border
                                gridCanvas:appendElements({
                                    {
                                        type = "rectangle",
                                        action = "stroke",
                                        strokeColor = { alpha = 0.1, red = 1, green = 1, blue = 1 },
                                        strokeWidth = 0.5,
                                        frame = frame2,
                                    },
                                })
                                -- Compose the 3-char code
                                local code = prefixPath .. k0 .. k1 .. k2
                                if should_draw(code) then
                                    seenCodes[code] = true
                                    gridCanvas:appendElements({
                                        {
                                            type = "text",
                                            text = code,
                                            textFont = font.name,
                                            textSize = 8,
                                            textColor = font.color,
                                            frame = {
                                                x = frame2.x + frame2.w / 2 - 10,
                                                y = frame2.y + frame2.h / 2 - 8,
                                                w = 20,
                                                h = 16,
                                            },
                                        }
                                    })
                                end
                            end
                        end
                        -- Draw the 2-char code text centered in level 1 cell
                        local code1 = prefixPath .. k0 .. k1
                        if should_draw(code1) then
                            seenCodes[code1] = true
                            gridCanvas:appendElements({
                                {
                                    type = "text",
                                    text = code1,
                                    textFont = font.name,
                                    textSize = 12,
                                    textColor = font.color,
                                    frame = {
                                        x = frame1.x + frame1.w / 2 - 12,
                                        y = frame1.y + frame1.h / 2 - 12,
                                        w = 24,
                                        h = 24,
                                    },
                                }
                            })
                        end
                    end
                end
                -- draw the 1-char (level-0) code
                local code0 = prefixPath .. k0
                if should_draw(code0) then
                    seenCodes[code0] = true
                    gridCanvas:appendElements({
                        {
                            type = "text",
                            text = code0,
                            textFont = font.name,
                            textSize = 20,
                            textColor = font.color,
                            frame = {
                                x = frame0.x + frame0.w / 2 - 14,
                                y = frame0.y + frame0.h / 2 - 16,
                                w = 28,
                                h = 32,
                            },
                        }
                    })
                end
            end
        end
    else
        -- Original drawGrid behavior for currentLevel > 0
        for row = 0, 2 do
            for col = 0, 2 do
                local index = row * 3 + col + 1
                local label = gridKeys[index]
                gridCanvas:appendElements({
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
                        textSize = math.max(6, font.size),
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

        if currentLevel < maxLevel - 1 then
            local w3, h3 = rect.w / 3, rect.h / 3
            for row = 0, 2 do
                for col = 0, 2 do
                    local index = row * 3 + col + 1
                    local key = gridKeys[index]
                    local subRect = {
                        x = rect.x + col * w3,
                        y = rect.y + row * h3,
                        w = w3,
                        h = h3,
                    }
                    local canvas = hs.canvas.new(subRect):show()
                    subGrids[key] = canvas

                    canvas:appendElements({
                        type = "rectangle",
                        action = "stroke",
                        strokeColor = { alpha = 0.15, red = 1, green = 1, blue = 1 },
                        strokeWidth = 0.5,
                    })

                    local pw, ph = subRect.w / 3, subRect.h / 3
                    for subRow = 0, 2 do
                        for subCol = 0, 2 do
                            local subIndex = subRow * 3 + subCol + 1
                            local subKey = gridKeys[subIndex]
                            canvas:appendElements({
                                {
                                    type = "rectangle",
                                    action = "stroke",
                                    strokeColor = { alpha = 0.1, red = 1, green = 1, blue = 1 },
                                    strokeWidth = 0.5,
                                    frame = {
                                        x = subCol * pw,
                                        y = subRow * ph,
                                        w = pw,
                                        h = ph,
                                    },
                                },
                                {
                                    type = "text",
                                    text = subKey,
                                    textFont = font.name,
                                    textSize = math.max(6, font.size - 2),
                                    textColor = { alpha = 0.3, red = 1, green = 1, blue = 1 },
                                    frame = {
                                        x = subCol * pw + pw / 2 - 6,
                                        y = subRow * ph + ph / 2 - 12,
                                        w = 20,
                                        h = 24,
                                    },
                                }
                            })
                        end
                    end
                end
            end
        end
    end
end

local function refineGrid(key)
    for _, canvas in pairs(subGrids) do
        canvas:delete()
    end
    subGrids = {}

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
    for _, canvas in pairs(subGrids) do
        canvas:delete()
    end
    subGrids = {}
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