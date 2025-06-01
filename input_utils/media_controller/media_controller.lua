local master_eventtap = require("master_eventtap")
local vim_mode = require("vim.vim_core")
local Style = require("input_utils.media_controller.media_controller_styles")
--
local media_controller = {}

local modal = hs.hotkey.modal.new({"alt"}, "m")

local mediaKeyMap = {
    ["a"] = "BRIGHTNESS_DOWN",
    ["s"] = "BRIGHTNESS_UP",
    ["d"] = "SOUND_DOWN",
    ["f"] = "SOUND_UP",
    ["g"] = "MUTE",
    ["h"] = "PLAY",
    ["j"] = "PREVIOUS",
    ["k"] = "NEXT",
    ["z"] = "ILLUMINATION_DOWN",
    ["x"] = "ILLUMINATION_UP",
}

local bgCanvas = nil
local barCanvas = nil
local eventtap = nil

local function mergeTables(...)
    local merged = {}
    for _, list in ipairs({...}) do
        for _, el in ipairs(list) do
            table.insert(merged, el)
        end
    end
    return merged
end

local function drawProgressBar(frame, value)
    local barItems = {}
    local maxBars = 16
    local spacing = 2
    local barWidth = (frame.w - (maxBars - 1) * spacing) / maxBars
    local activeCount = math.floor((value / 100) * maxBars + 0.5)

    table.insert(barItems, {
        type = "rectangle",
        action = "fill",
        frame = { x = frame.x, y = frame.y + frame.h + 2, w = frame.w, h = 2 },
        fillColor = Style.color.activeBarColor
    })

    for i = 1, maxBars do
        local color = i <= activeCount and Style.color.activeBarColor or Style.color.inactiveBarColor
        table.insert(barItems, {
            type = "rectangle",
            action = "fill",
            frame = {
                x = frame.x + (i - 1) * (barWidth + spacing),
                y = frame.y,
                w = barWidth,
                h = frame.h
            },
            fillColor = color
        })
    end
    return barItems
end

local function drawPanel()
    if bgCanvas then
        bgCanvas:delete()
    end

    local screenFrame = hs.screen.mainScreen():frame()
    local width = 712
    local height = 180
    local x = screenFrame.x + (screenFrame.w - width) / 2
    local y = screenFrame.y + (screenFrame.h - height) / 2

    bgCanvas = hs.canvas.new{x = x, y = y, w = width, h = height}
    -- bgCanvas = hs.canvas.new{x = x, y = y, w = width, h = height}:show()
    bgCanvas:appendElements(
        mergeTables(
            { Style.bgPanel },
            Style.Brightness("a", "s"),
            Style.Sound("d", "f", "g"),
            Style.MediaControl("h", "j", "k"),
            Style.Illumination("z", "x")
        )
    )

    -- barCanvas = hs.canvas.new{x = x, y = y, w = width, h = height}:show()
    barCanvas = hs.canvas.new{x = x, y = y, w = width, h = height}
    local brightnessValue = hs.brightness.get() or 0
    local soundValue = hs.audiodevice.defaultOutputDevice():volume() or 0
    barCanvas:appendElements(
        mergeTables(
            drawProgressBar(Style.brightnessBar, brightnessValue),
            drawProgressBar(Style.soundBar, soundValue)
        )
    )

    bgCanvas:show(0.25)
    barCanvas:show(0.25)
end

local function updateBarValue()
    local brightnessValue = hs.brightness.get() or 0
    local soundValue = hs.audiodevice.defaultOutputDevice():volume() or 0
    if barCanvas then
        barCanvas:replaceElements(
            mergeTables(
                drawProgressBar(Style.brightnessBar, brightnessValue),
                drawProgressBar(Style.soundBar, soundValue)
            )
        )
    end
end

local function highlightKey(key, restore)
    if not bgCanvas then return end
    restore = restore or false
    local id1 = "label_" .. key
    local id2 = "rect_" .. key
    local ele1 = bgCanvas[id1]
    local ele2 = bgCanvas[id2]
    if ele1 and ele2 then
        if not restore then
            ele1.textColor = Style.color.pressedTextColor
            ele2.fillColor = Style.color.pressedBgColor
        else
            ele1.textColor = Style.color.normalTextColor
            ele2.fillColor = Style.color.normalBgColor
        end
    end
end

local function triggerMedia(key)
    local action = mediaKeyMap[key]
    if not action then return end
    local event = hs.eventtap.event.newSystemKeyEvent(action, true)
    highlightKey(key)
    hs.timer.doAfter(0.2, function()
        highlightKey(key, true)
    end)
    event:post()
    local eventUp = hs.eventtap.event.newSystemKeyEvent(action, false)
    eventUp:post()
    if action:find("BRIGHTNESS") or action:find("SOUND") then
        hs.timer.doAfter(0.1, function()
            updateBarValue()
        end)
    end
end

local function mediaHandler(event)
    local key = event:getCharacters(true)
    if key == nil then return false end
    if mediaKeyMap[key] then
        triggerMedia(key)
        return true
    elseif key == "escape" then
        modal:exit()
        return true
    end
    return false
end

-- Block Apple Music from auto-launching
local musicBlocker = hs.application.watcher.new(function(appName, eventType, appObject)
    if eventType == hs.application.watcher.launched and appName == "Music" then
        appObject:kill()
    end
end)

function modal:entered()
    if vim_mode then
        vim_mode.exitVim()
    end
    drawPanel()
    master_eventtap.register(mediaHandler)
    musicBlocker:start()
end

function modal:exited()
    if bgCanvas then bgCanvas:delete(0.2) bgCanvas = nil end
    if barCanvas then barCanvas:delete(0.2) barCanvas = nil end
    if eventtap then eventtap:stop() eventtap = nil end
    master_eventtap.unregister(mediaHandler)
    musicBlocker:stop()
end

modal:bind({},"escape",function ()
    modal:exit()
end)

return media_controller