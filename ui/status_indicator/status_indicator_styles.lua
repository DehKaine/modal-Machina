local Color = require("hs_enhance.color")
--
local style = {}

local offsetX = 432
-- local offsetX = 432 + 36

style.color = {
    modal_label       = Color.SetByHex("b1d1a5"),
    vim_text          = Color.SetByHex("343434"),
    vim_label         = Color.SetByHex("b1d1a5"),
    vim_cmd_bar       = Color.SetByHex("464646"),
    cursor_navi_label = Color.SetByHex("b1d1a5"),
    media_ctrl_label  = Color.SetByHex("b1d1a5"),
    memocho_label     = Color.SetByHex("b1d1a5"),
}

local function SetLabel (textName, frame)
    local text = {
        id            = "txt_" .. textName,
        type          = "text",
        text          = textName,
        textFont      = "Adelle Sans Devanagari Extrabold",
        textSize      = 14,
        textColor     = style.color.vim_text,
        textAlignment = "center",
        frame         = { x = frame.x, y = frame.y - 6, w = frame.w, h = frame.h + 6 }
    }
    local label = {
        id               = "label_" .. textName,
        type             = "rectangle",
        action           = "fill",
        fillColor        = style.color.vim_label,
        roundedRectRadii = { xRadius = 2, yRadius = 2 },
        frame            = { x = frame.x, y = frame.y, w = frame.w, h = frame.h }
    }
    return text, label
end

style.MachinaIcon = function (menubarFrame)
    return {
        {
            type        = "rectangle",
            action      = "fill",
            fillColor   = style.color.vim_cmd_bar,
            frame       = {
                x = menubarFrame.w - offsetX - 22,
                y = 4,
                w = 22,
                h = 16
            },
            roundedRectRadii = { xRadius = 2, yRadius = 2 },
        },
        {
            id          = "machina_label",
            type        = "text",
            text        = "M",
            textFont    = "Adelle Sans Devanagari Bold",
            textSize    = 14,
            textColor   = style.color.vim_label,
            textAlignment = "center",
            frame       = {
                x = menubarFrame.w - offsetX - 22,
                y = 4 - 6,
                w = 22,
                h = 16 + 8
            }
        }
    }
end

style.vim_statusbar = {
    whole_width = 110,
    label_rect = { x = 0, y = 4, w = 44, h = 16 },
    cmd_bar_rect = { x = 48, y = 4, w = 62, h = 16 },
}

style.VimStatus = function(textName, menubarFrame)
    local labelFrame = {
        x = menubarFrame.w - offsetX - style.vim_statusbar.whole_width,
        y = style.vim_statusbar.label_rect.y,
        w = style.vim_statusbar.label_rect.w,
        h = style.vim_statusbar.label_rect.h
    }
    local cmdbarFrame = {
        x = labelFrame.x + style.vim_statusbar.cmd_bar_rect.x,
        y = style.vim_statusbar.cmd_bar_rect.y,
        w = style.vim_statusbar.cmd_bar_rect.w,
        h = style.vim_statusbar.cmd_bar_rect.h
    }
    local text, label = SetLabel(textName, labelFrame)
    return {
        label,text,
        {
            id          = "cmd_bar",
            type        = "rectangle",
            action      = "fill",
            fillColor   = style.color.vim_cmd_bar,
            frame       = { x = cmdbarFrame.x, y = cmdbarFrame.y, w = cmdbarFrame.w, h = cmdbarFrame.h },
            roundedRectRadii = { xRadius = 2, yRadius = 2 },
        },
        {
            id            = "cmd_text",
            type          = "text",
            text          = "",
            textFont      = "Monaco",
            textSize      = 11,
            textColor     = style.color.vim_label,
            textAlignment = "left",
            frame = {
                x = cmdbarFrame.x + 3,
                y = cmdbarFrame.y + 1,
                w = cmdbarFrame.w,
                h = cmdbarFrame.h + 8
            }
        }
    }
end

style.VimExecutedIcon = function(menubarFrame)
    return {
        id    = "vim_executed_icon",
        type  = "image",
        image = hs.image.imageFromPath( "~/.HAMMERSPOON/ui/sprite/status_indicator/vim_executed_icon.png"),
        frame = {
            x = menubarFrame.w - offsetX - 15,
            y = 5,
            w = 13,
            h = 13
        },
        imageAlpha = 0
    }
end

style.CursorNaviStatus = function(frame)
    return {
        frame
    }
end

return style