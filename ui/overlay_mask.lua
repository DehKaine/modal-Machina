local OverlayMask = {}
OverlayMask.__index = OverlayMask

function OverlayMask.new(focusFrame, screenFrame)
    local self = setmetatable({}, OverlayMask)
    focusFrame = focusFrame or hs.screen.mainScreen():fullFrame()
    screenFrame = screenFrame or hs.screen.mainScreen():fullFrame()

    self.canvas = hs.canvas.new(screenFrame):appendElements({
        {
            type = "rectangle",
            action = "fill",
            fillColor = { alpha = 0.5, red = 0, green = 0, blue = 0 },
            frame = {
                x = 0, y = 0,
                w = screenFrame.w,
                h = screenFrame.h
            }
        },
        {
            type = "rectangle",
            action = "fill",        -- fill, but...
            compositeRule = "clear",-- ...with clear blend mode
            fillColor      = { alpha = 0 }, -- color ignored, but explicit
            frame = {
                x = focusFrame.x,
                y = focusFrame.y,
                w = focusFrame.w,
                h = focusFrame.h
            }
        }
    })

    self.canvas:level(hs.canvas.windowLevels.overlay)
    self.canvas:behavior({ hs.canvas.windowBehaviors.canJoinAllSpaces })

    return self
end

function OverlayMask:focusTo(newFocusFrame)
    self.canvas[2].frame = newFocusFrame
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