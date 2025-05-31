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

local function drawPanel()
    if bgCanvas then
        bgCanvas:delete()
    end

    local screenFrame = hs.screen.mainScreen():frame()
    local width = 712
    local height = 180
    local x = screenFrame.x + (screenFrame.w - width) / 2
    local y = screenFrame.y + (screenFrame.h - height) / 2

    bgCanvas = hs.canvas.new{x = x, y = y, w = width, h = height}:show()
    bgCanvas:appendElements(
        mergeTables(
            { Style.bgPanel },
            Style.Brightness("a", "s"),
            Style.Sound("d", "f", "g"),
            Style.MediaControl("h", "j", "k"),
            Style.Illumination("z", "x")
        )
    )

    local keys = {}
    for k, _ in pairs(mediaKeyMap) do
        table.insert(keys, k)
    end
    table.sort(keys)


 end

local function triggerMedia(key)
    local action = mediaKeyMap[key]
    if not action then return end
    local event = hs.eventtap.event.newSystemKeyEvent(action, true)
    event:post()
    local eventUp = hs.eventtap.event.newSystemKeyEvent(action, false)
    eventUp:post()
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
    if bgCanvas then bgCanvas:delete() bgCanvas = nil end
    if eventtap then eventtap:stop() eventtap = nil end
    master_eventtap.unregister(mediaHandler)
    musicBlocker:stop()
end

modal:bind({},"escape",function ()
    modal:exit()
end)

return media_controller