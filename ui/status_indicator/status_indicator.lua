local Style = require("ui.status_indicator.status_indicator_styles")
--
local Indicator = {}
Indicator.Vim = {}

local menubarFrames = {}
--
local machina_icon_canvas = {}
local vim_indicator_canvases = {}
-- local cursor_navigator_canvas = nil
-- local media_controller_canvas = nil
local indicatorInitialized = false

local function GetAllMenubarFrames()
    menubarFrames = {}
    for _, screen in ipairs(hs.screen.allScreens()) do
        local fullFrame = screen:fullFrame()
        local menubarFrame = { x = fullFrame.x, y = fullFrame.y, w = fullFrame.w, h = 24 }
        table.insert(menubarFrames, menubarFrame)
    end
end

Indicator.ShowMachinaIcon = function()
    if indicatorInitialized then
        for _, canvas in ipairs(machina_icon_canvas) do
            canvas:show()
        end
        return
    else
        GetAllMenubarFrames()
        machina_icon_canvas = {}
        for i, menubarFrame in ipairs(menubarFrames) do
            local canvas = hs.canvas.new{
                x = menubarFrame.x,
                y = menubarFrame.y,
                w = menubarFrame.w,
                h = menubarFrame.h
            }:level("status")
            canvas:appendElements(
                Style.MachinaIcon(menubarFrame)
            )
            canvas:show()
        end
        indicatorInitialized = true
    end
end

Indicator.HideMachinaIcon = function()
    if not indicatorInitialized then
        return
    end
    for _, canvas in ipairs(machina_icon_canvas) do
        canvas:hide()
    end
    machina_icon_canvas = {}
end

function Indicator.Vim.Show()
    GetAllMenubarFrames()
    vim_indicator_canvases = {}
    for i, menubarFrame in ipairs(menubarFrames) do
        local canvas = hs.canvas.new{
            x = menubarFrame.x,
            y = menubarFrame.y,
            w = menubarFrame.w,
            h = menubarFrame.h
        }:level("status")
         :behavior({"canJoinAllSpaces"})
        canvas:appendElements(
            Style.VimStatus("VIM", menubarFrame)
        )
        canvas:show()
        vim_indicator_canvases[i] = canvas
    end
end

function Indicator.Vim.Update(cmd)
    cmd = cmd or ""
    for _, canvas in ipairs(vim_indicator_canvases) do
        local cmdTextField = canvas["cmd_text"]
        cmdTextField.text = cmd
    end
end

function Indicator.Vim.Close()
    Indicator.ShowMachinaIcon()
    for _, canvas in ipairs(vim_indicator_canvases) do
        canvas:hide()
        canvas:delete()
        canvas = nil
    end
    vim_indicator_canvases = {}
end

hs.hotkey.bind({"cmd", "alt"}, "v", function()
    -- Test Func
    Indicator.Vim.Show()
end)

return Indicator