local master_eventtap = require("master_eventtap")
local Configs = require("configs.configs")
--
local memocho = {}

local overlay = nil
local isImageVisible = false

function memocho.displayImage(path)
    hs.alert.show("Displaying image at: " .. path)
    if overlay then
        overlay:delete()
        overlay = nil
    end
    local image = hs.image.imageFromPath(path)
    if not image then
        hs.alert.show("⚠️ imageFromPath failed: " .. path)
        return
    end
    local screenFrame = hs.screen.mainScreen():frame()
    overlay = hs.canvas.new(screenFrame)
    overlay:appendElements({
        type = "image",
        image = image,
        frame = { x = 0, y = 0, w = screenFrame.w, h = screenFrame.h },
        scaling = "scaleProportionallyUpOrDown",
    })
    overlay:show()
    isImageVisible = true
end

function memocho.show()
    hs.alert.show("Showing image mode")
    local path = Configs.memocho.keymap_image.path
    if path then
        memocho.displayImage(path)
    else
        hs.alert.show("No path found in config")
    end
end

local function memochoHandler(event)
    local keyCode = event:getKeyCode()
    local key = hs.keycodes.map[keyCode]
    if key == "escape" then
        hs.alert.show("Exiting image view")
        if overlay then
            overlay:delete()
            overlay = nil
        end
        memocho.stop()
        return true
    end
    return false
end

function memocho.start()
    memocho.show()
    master_eventtap.register(memochoHandler)
end

function memocho.stop()
    if overlay then overlay:delete() end
    overlay = nil
    isImageVisible = false
    master_eventtap.unregister(memochoHandler)
end

hs.hotkey.bind({"ctrl", "shift"}, "m", function()
    memocho.start()
end)

return memocho