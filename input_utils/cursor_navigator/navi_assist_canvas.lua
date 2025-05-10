local Style = require("input_utils.cursor_navigator.canvas_style")
local Mask = require("ui.overlay_mask")
--
local NaviCanvas = {}
NaviCanvas.__index = NaviCanvas

function NaviCanvas:new()
    local self = setmetatable({}, NaviCanvas)
    self.grid = nil
    self.mask = nil
    self.anchor = nil
    return self
end

function NaviCanvas:drawGrid()
    
end

function NaviCanvas:refineGrid()
    
end

function NaviCanvas:drawMask()
    if self.mask then self.mask:destroy() end
    self.mask = Mask:new()
    self.mask:show()
end

function NaviCanvas:refineMask(focusArea)
    if self.mask then
        self.mask:focusTo(focusArea)
    end
end

return NaviCanvas