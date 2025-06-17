local Style = require("ui.status_indicator.status_indicator_styles")
--
local Indicator = {}

local modal_icon_canvas = nil
local vim_indicator_canvas = nil
-- local cursor_navigator_canvas = nil
-- local media_controller_canvas = nil

local function GetAllMenubarFrames()
    local frames = {}
    for _, screen in ipairs(hs.screen.allScreens()) do
        local fullFrame = screen:fullFrame()
        local menubarFrame = {
            x = fullFrame.x,
            y = fullFrame.y,
            w = fullFrame.w,
            h = 24
        }
        table.insert(frames, menubarFrame)
    end
    return frames
end

Indicator.ShowModalIcon = function()
    if not modal_icon_canvas then
        modal_icon_canvas = hs.canvas.new{
            x = 0,
            y = 0,
            w = 0,
            h = 0
        }:level("status")
         :behavior({"canJoinAllSpaces"})
    end
    modal_icon_canvas:show()
end

Indicator.ShowVimIndicator = function()
    -- local menubarFrames = GetAllMenubarFrames()
    -- for _, menubarFrame in ipairs(menubarFrames) do
    --     -- create a new canvas with the menubar frame and proper level/behavior
    --     local indicator_canvas = hs.canvas.new{
    --         x = menubarFrame.x,
    --         y = menubarFrame.y,
    --         w = menubarFrame.w,
    --         h = menubarFrame.h
    --     }:level("status")
    --      :behavior({"canJoinAllSpaces"})
    --     -- append the styled elements and show
    --     indicator_canvas:appendElements(
    --         Style.VimStatus("VIM", menubarFrame)
    --     )
    --     indicator_canvas:show()
    -- end
    local fullFrame = hs.screen.mainScreen():fullFrame()
    local menubarFrame = {
        x = fullFrame.x,
        y = fullFrame.y,
        w = fullFrame.w,
        h = 24
    }
    vim_indicator_canvas = hs.canvas.new{
        x = menubarFrame.x,
        y = menubarFrame.y,
        w = menubarFrame.w,
        h = menubarFrame.h
    }:level("status")
     :behavior({"canJoinAllSpaces"})

    vim_indicator_canvas:appendElements(
        Style.VimStatus("VIM", menubarFrame)
    )
 end

hs.hotkey.bind({"cmd", "alt"}, "v", function()
    Indicator.ShowVimIndicator()
end)

return Indicator