local Style = require("input_utils.cursor_navigator.cursor_navi_styles")
--
local Crosshair = {}
Crosshair.__index = Crosshair

function Crosshair:new()
    local self = setmetatable({}, Crosshair)
    self.canvas = nil
    self.built = false
    self.frame = nil 
    self.cx, self.cy = nil, nil
    return self
end

-- 更新所有坐标，使十字始终以 (x,y) 为中心
function Crosshair:moveTo(x, y)
    self.cx, self.cy = x, y
    if not self.built then return end

    local offsetX, offsetY = self.frame.x, self.frame.y
    local localX,  localY  = x - offsetX, y - offsetY
    local w, h  = self.frame.w, self.frame.h
    local size  = 10

    -- center 十字短线
    self.canvas[1].coordinates = { {x = localX - size, y = localY}, {x = localX + size, y = localY} }
    self.canvas[2].coordinates = { {x = localX, y = localY - size}, {x = localX, y = localY + size} }

    -- expand 横、竖线
    self.canvas[3].coordinates = { {x = 0, y = localY}, {x = w, y = localY} }
    self.canvas[4].coordinates = { {x = localX, y = 0}, {x = localX, y = h} }
end

function Crosshair:hide()
    if self.canvas then self.canvas:hide() end
end

function Crosshair:show(rect)
    if not rect or not rect.w or not rect.h then return end
    -- 若没有 canvas，则创建
    if not self.canvas then
        self.canvas = hs.canvas.new{
            x = rect.x, y = rect.y, w = rect.w, h = rect.h
        }
    else
        self.canvas:frame(rect)
    end
    
    self.frame = rect
    self.cx = rect.x + rect.w / 2
    self.cy = rect.y + rect.h / 2
    self.built = false
    
    if not self.built then
        local w, h = rect.w, rect.h

        -- 顺序：center 后绘制，expand 最后绘制，覆盖其上
        for _, elem in ipairs(Style.crosshairCenter(self.cx, self.cy)) do
            self.canvas[#self.canvas + 1] = elem
        end
        for _, elem in ipairs(Style.crosshairExpand(self.cx, self.cy, w, h)) do
            self.canvas[#self.canvas + 1] = elem
        end

        self.built = true
    end

    self:moveTo(self.cx, self.cy)
    self.canvas:show()
end

function Crosshair:destroy()
    if self.canvas then
        self.canvas:delete()
        self.canvas = nil
    end
    self.built = false
    self.frame = nil
    self.cx, self.cy = nil, nil
end

return Crosshair