local OverlayMask = {}
OverlayMask.__index = OverlayMask

function OverlayMask.new(screenFrame)
    local self = setmetatable({}, OverlayMask)
    screenFrame = screenFrame or hs.screen.mainScreen():fullFrame()

    self.canvas = hs.canvas.new(screenFrame):appendElements({
        {
            type = "rectangle",
            action = "fill",
            fillColor = { black = 0, alpha = 0.5 },
            frame = {
                x = 0, y = 0,
                w = screenFrame.w,
                h = screenFrame.h
            }
        },
        {
            type = "rectangle",
            action = "clear",
            frame = {
                x = screenFrame.w / 2 - 100,
                y = screenFrame.h / 2 - 100,
                w = 200,
                h = 200
            }
        }
    })

    self.canvas:level(hs.canvas.windowLevels.overlay)
    self.canvas:behavior({ hs.canvas.windowBehaviors.canJoinAllSpaces })

    return self
end

function OverlayMask:focusTo(rect)
    self.canvas[2].frame = rect
end

function OverlayMask:updateFrame(rect)
    self.canvas[2].frame = rect
end

function OverlayMask:show()
    self.canvas:show()
end

function OverlayMask:hide()
    self.canvas:hide()
end

function OverlayMask:destroy()
    self.canvas:delete()
end

return OverlayMask