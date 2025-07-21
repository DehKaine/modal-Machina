local master_eventtap = require("master_eventtap")
local vim_mode = require("vim.vim_core")
local Style = require("input_utils.media_controller.media_controller_styles")
--
local visual_hint = {}

local modal = hs.hotkey.modal.new({"alt"}, "l")

local function hintHandler(event)
    local key = event:getCharacters(true)
    if key == nil then return false end
end

function modal:entered()
    if vim_mode then
        vim_mode.exitVim()
    end
    master_eventtap.register(hintHandler)
end

function modal:exited()
    master_eventtap.unregister(hintHandler)
end

modal:bind({},"escape",function ()
    modal:exit()
end)

return visual_hint