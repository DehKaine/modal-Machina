local multi_keys = {}

local function remapMultiKeys()
    local ctrl = {"ctrl"}
    hs.hotkey.bind(ctrl, "a", function() hs.eventtap.keyStroke({}, "left") end)
    hs.hotkey.bind(ctrl, "s", function() hs.eventtap.keyStroke({}, "down") end)
end

remapMultiKeys()

return multi_keys