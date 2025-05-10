local Style = require("input_utils.cursor_navigator.canvas_style")
local Mask = require("ui.overlay_mask")
--
local NaviCanvas = {}
NaviCanvas.__index = NaviCanvas

function NaviCanvas:new()
    local self = setmetatable({}, NaviCanvas)
    self.mask = nil
    self.grid = nil
    self.anchor = nil
    return self
end

function NaviCanvas:drawGrid(frame)
    frame = frame or hs.screen.mainScreen():fullFrame()
    if self.grid then self.grid:delete() end
    self.grid = hs.canvas.new(frame):show()
    self.grid:appendElements(Style.grid)
end

function NaviCanvas:refineGrid(frame)
    if self.grid then self.grid:delete() end
    self.grid = hs.canvas.new(frame):show()
    self.grid:appendElements(Style.grid)
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

function NaviCanvas:destroy()
    if self.mask then self.mask:destroy() self.mask = nil end
    if self.grid then self.grid:delete() self.grid = nil end
    if self.anchor then self.anchor:delete() self.anchor = nil end
end

return NaviCanvas