local tween = {}

function tween.move(from, to, duration, stepCallback, doneCallback)
    duration = duration or 0.2
    doneCallback = doneCallback or nil

    local fps = 60
    local steps = math.floor(duration * fps)
    local step = 0
    local interval = duration / steps

    local dx = to.x - from.x
    local dy = to.y - from.y

    hs.timer.doUntil(
        function() return step >= steps end,
        function()
            step = step + 1
            local progress = step / steps
            local easedT = 1 - (1 - progress) ^ 2
            local pos = {
                x = from.x + dx * easedT,
                y = from.y + dy * easedT
            }
            stepCallback(pos)
        end,
        interval,
        doneCallback
    )
end

return tween