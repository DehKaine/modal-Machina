-- master eventtap manager

local master_eventtap = {}

local listeners = {}

-- Register
function master_eventtap.register(handler)
    table.insert(listeners, handler)
end

function master_eventtap.start()
    master_eventtap.eventtap = hs.eventtap.new(
    {hs.eventtap.event.types.keyDown, hs.eventtap.event.types.flagsChanged}, 
    function(event)
        for _, handler in ipairs(listeners) do
            local handled = handler(event)
            if handled then
                return true
            end
        end
        return false
    end)
    master_eventtap.eventtap:start()
end

-- Unregister
function master_eventtap.unregister(handler)
    for i, h in ipairs(listeners) do
        if h == handler then
            table.remove(listeners, i)
            break
        end
    end
end

return master_eventtap

