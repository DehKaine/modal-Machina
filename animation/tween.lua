local tween = {}

function tween.move(from, to, duration, stepCallback, doneCallback)
    duration = duration or 0.2
    local steps = 60
    local step = 0
    local interval = duration / steps

    -- local isVector = type(from) == "table" 
    --                  and type(to) == "table" 
    --                  and from.x and from.y and to.x and to.y

    -- 重载，当参数1为obj且参数2为坐标时，直接移动obj至坐标，但obj必须有对应的getPosition方法
    -- if type(from) == "table" and type(to) == "table"
    --                   and type(from.getPosition) == "function"
    --                   and type(from.moveTo) == "function" then
    --     local obj = from
    --     local target = to
    --     from = obj:getPosition()
    --     to = target
    --     stepCallback = function(vec)
    --         obj:moveTo(vec.x, vec.y)
    --     end
    --     isVector = true
    -- end

    stepCallback = stepCallback or function() end

    hs.timer.doUntil(
        function() return step >= steps end,
        function()
            step = step + 1
            local t = step / steps
            local easedT = 1 - (1 - t)^2 -- EaseOutQuad

            -- local val
            -- if isVector then
            --     val = {
            --         x = from.x + (to.x - from.x) * easedT,
            --         y = from.y + (to.y - from.y) * easedT,
            --     }
            -- else
            --     val = from + (to - from) * easedT
            -- end

            -- stepCallback(val)
        end,
        interval,
        doneCallback
    )
end

return tween