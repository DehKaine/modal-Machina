local hs_inspect = require("hs.inspect")
local Style = require("input_utils.cursor_navigator.crosshair_style")
--
local Crosshair = {}
Crosshair.__index = Crosshair

function Crosshair:new(rect)
    -- allow caller to pass either screen object or rect table
    local frame
    if type(rect) == "userdata" and rect.frame then      -- e.g. hs.screen object
        frame = rect:frame()
    elseif type(rect) == "table" and rect.w and rect.h then
        frame = rect
    else
        error("Crosshair:new ⇒ rect must be screen or frame table")
    end

    local self = setmetatable({}, Crosshair)
    self.frame = frame
    self.canvas = hs.canvas.new{
        x = frame.x, y = frame.y, w = frame.w, h = frame.h
    }
    self.built = false

    self.cx, self.cy = frame.w/2, frame.h/2

    return self
end

-- 更新所有坐标，使十字始终以 (x,y) 为中心
function Crosshair:moveTo(x, y)
    self.cx, self.cy = x, y
    if not self.built then return end   -- no elements yet

    local w, h  = self.frame.w, self.frame.h
    local size  = 10   -- 与 Style.center 保持一致

    -- expand 横、竖线（元素 1、2）
    self.canvas[1].coordinates = { {x = 0, y = y}, {x = w, y = y} }
    self.canvas[2].coordinates = { {x = x, y = 0}, {x = x, y = h} }

    -- center 十字短线（元素 3、4）
    self.canvas[3].coordinates = { {x = x - size, y = y}, {x = x + size, y = y} }
    self.canvas[4].coordinates = { {x = x, y = y - size}, {x = x, y = y + size} }
end

function Crosshair:hide()
    if self.canvas then self.canvas:hide() end
end

function Crosshair:show()
    if not self.canvas then return end
    if not self.built then
        local w, h = self.frame.w, self.frame.h
        for _, elem in ipairs(Style.expand(self.cx, self.cy, w, h)) do
            self.canvas[#self.canvas + 1] = elem
        end
        for _, elem in ipairs(Style.center(self.cx, self.cy)) do
            self.canvas[#self.canvas + 1] = elem
        end
        self.built = true
    end
    self.canvas:show()
end

function Crosshair:destroy()
    
end

return Crosshair