
local master_eventtap = require("master_eventtap")

local memocho = {}

local overlay = nil
local imageMap = {}

function memocho.show()
    hs.alert.show("Memocho: Show Overlay")
end

local function memochoHandler(event)
    memocho.show()
    local key = event:getCharacters(true)
    if key == "escape" then
        memocho.stop()
        return true
    end
end 

function memocho.start()
    memocho.show()
    master_eventtap.register(memochoHandler)
end

function memocho.stop()
    if overlay then overlay:delete() end
    overlay = nil
    master_eventtap.unregister(memochoHandler)
end

hs.hotkey.bind({"ctrl", "shift"}, "m", function()
    memocho.start()
end)

return memocho