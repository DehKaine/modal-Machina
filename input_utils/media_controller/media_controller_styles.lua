local Color = require("hs_enhance.color")
--
local style = {}

local atlas = hs.image.imageFromPath("~/.HAMMERSPOON/ui/sprite/media_controller/media_controller_atlas.png")
local function setSprite( x, y, w, h )
    local slice = atlas:croppedCopy(hs.geometry.rect(x, y, w, h))
    return slice
end

style.color = {
    normalTextColor     = Color.SetByHex("b1d1a5"),
    pressedTextColor    = Color.SetByHex("343434"),
    selectedTextColor   = Color.SetByHex("464646"),
    headerColor         = Color.SetByHex("343434"),
    normalBgColor       = Color.SetByHex("464646"),
    pressedBgColor      = Color.SetByHex("b1d1a5"),
    selectedEleColor    = Color.SetByHex("98aaac"),
    activeBarColor      = Color.SetByHex("b1d1a5"),
    inactiveBarColor    = Color.SetByHex("343434"),
    barUnderlayColor    = Color.SetByHex("272727"),
    splitLineColor      = Color.SetByHex("343434"),
}

local function SetVerticalLine(frame)
    return {
        type = "rectangle",
        action = "fill",
        fillColor = style.color.splitLineColor,
        frame = { x = frame.x - 1, y = frame.y, w = 2, h = frame.h + 28 }
    }
end

local function SetLabel(textName, frame)
    local underlay = {
            id = "rect_" .. textName,
            type = "rectangle",
            action = "fill",
            fillColor = style.color.normalBgColor,
            frame = frame
        }
    local label = {
            id    = "label_" .. textName,
            type  = "text",
            text  = textName,
            textFont  = "Monaco",
            textSize  = 18,
            textColor = style.color.normalTextColor,
            textAlignment = "center",
            frame = { x = frame.x, y = frame.y + 1, w = frame.w, h = frame.h}
        }
    local divider = {
            type = "rectangle",
            action = "fill",
            fillColor = style.color.splitLineColor,
            frame = { x = frame.x, y = frame.y - 2, w = frame.w, h = 2 }
        }
    return underlay, label, divider
end

local function SetIcon(css)
    local underlay = {
        type = "rectangle",
        action = "fill",
        fillColor = style.color.normalBgColor,
        frame = css.bgRect
    }
    local image = {
        type  = "image",
        image = css.icon,
        frame = css.iconRect
    }
    return underlay, image
end

local function SetHeader(css,progressbar)
    local color = style.color.headerColor
    if progressbar then
        color = style.color.barUnderlayColor
    end
    return {
        type = "rectangle",
        action = "fill",
        fillColor = color,
        frame = css.headerRect
    }
end

style.bgPanel = {
    type = "image",
    image = setSprite(2, 164, 1784, 424),
    frame = { x = 0, y = 0, w = 712, h = 180 }
}

style.brightnessBar = { x = 22, y = 54, w = 128, h = 8 }

style.brightnessDown = {
    icon       = setSprite( 2, 2, 160, 160 ),
    iconRect   = { x = 22, y = 64, w = 64, h = 64 },
    bgRect     = { x = 22, y = 64, w = 64, h = 64 },
    headerRect = { x = 22, y = 54, w = 64, h = 8 },
    textRect   = { x = 22, y = 128, w = 64, h = 28 },
}

style.brightnessUp = {
    icon       = setSprite( 164, 2, 160, 160 ),
    iconRect   = { x = 86, y = 64, w = 64, h = 64 },
    bgRect     = { x = 86, y = 64, w = 64, h = 64 },
    headerRect = { x = 86, y = 54, w = 64, h = 8 },
    textRect   = { x = 86, y = 128, w = 64, h = 28 },
}

style.Brightness = function(label1, label2)
    local css1 = style.brightnessDown
    local css2 = style.brightnessUp
    local textUnderlay1, textLabel1, divider1 = SetLabel(label1, css1.textRect)
    local textUnderlay2, textLabel2, divider2  = SetLabel(label2, css2.textRect)
    local iconUnderlay1, iconImage1 = SetIcon(css1)
    local iconUnderlay2, iconImage2 = SetIcon(css2)
    return {
        SetHeader(css1, true),
        iconUnderlay1, iconImage1, textUnderlay1, textLabel1, divider1,
        SetHeader(css2, true),
        iconUnderlay2, iconImage2, textUnderlay2, textLabel2, divider2,
        SetVerticalLine(css2.iconRect)
    }
end

style.soundBar = { x = 160, y = 54, w = 127, h = 8 }

style.soundDown = {
    icon       = setSprite( 326, 2, 160, 160 ),
    iconRect   = { x = 160, y = 64, w = 64, h = 64 },
    bgRect     = { x = 160, y = 64, w = 64, h = 92 },
    headerRect = { x = 160, y = 54, w = 64, h = 8 },
    textRect   = { x = 160, y = 128, w = 64, h = 28 },
}

style.soundUp = {
    icon       = setSprite( 488, 2, 160, 160 ),
    iconRect   = { x = 224, y = 64, w = 64, h = 64 },
    bgRect     = { x = 224, y = 64, w = 64, h = 92 },
    headerRect = { x = 224, y = 54, w = 64, h = 8 },
    textRect   = { x = 224, y = 128, w = 64, h = 28 },
}

style.mute = {
    icon          = setSprite( 650, 2, 160, 160 ),
    icon_selected = setSprite( 1622, 2, 160, 160 ),
    iconRect      = { x = 288, y = 64, w = 64, h = 64 },
    bgRect        = { x = 288, y = 64, w = 64, h = 92 },
    seletedRect   = { x = 290, y = 65, w = 61, h = 60 },
    headerRect    = { x = 288, y = 54, w = 64, h = 8 },
    textRect      = { x = 288, y = 128, w = 64, h = 28 },
}

style.Sound = function(label1, label2, label3)
    local css1 = style.soundDown
    local css2 = style.soundUp
    local css3 = style.mute
    local textUnderlay1, textLabel1, divider1 = SetLabel(label1, css1.textRect)
    local textUnderlay2, textLabel2, divider2  = SetLabel(label2, css2.textRect)
    local textUnderlay3, textLabel3, divider3  = SetLabel(label3, css3.textRect)
    local iconUnderlay1, iconImage1 = SetIcon(css1)
    local iconUnderlay2, iconImage2 = SetIcon(css2)
    local iconUnderlay3, iconImage3 = SetIcon(css3)
    local muteHeader = SetHeader(css3, true)
    muteHeader.id    = "mute_header"
    iconImage3.id    = "mute_icon_image"
    iconUnderlay3.id = "mute_icon_underlay"
    return {
        SetHeader(css1, true),
        iconUnderlay1, iconImage1, textUnderlay1, textLabel1, divider1,
        SetHeader(css2, true),
        iconUnderlay2, iconImage2, textUnderlay2, textLabel2, divider2,
        muteHeader,
        iconUnderlay3, iconImage3, textUnderlay3, textLabel3, divider3,
        SetVerticalLine(css2.iconRect), SetVerticalLine(css3.iconRect)

    }
end

style.prev = {
    icon       = setSprite( 812, 2, 160, 160 ),
    iconRect   = { x = 362, y = 64, w = 64, h = 64 },
    bgRect     = { x = 362, y = 64, w = 64, h = 92 },
    headerRect = { x = 362, y = 54, w = 64, h = 8 },
    textRect   = { x = 362, y = 128, w = 64, h = 28 },
}

style.playPause = {
    icon       = setSprite( 974, 2, 160, 160 ),
    iconRect   = { x = 426, y = 64, w = 64, h = 64 },
    bgRect     = { x = 426, y = 64, w = 64, h = 92 },
    headerRect = { x = 426, y = 54, w = 64, h = 8 },
    textRect   = { x = 426, y = 128, w = 64, h = 28 },
}

style.next = {
    icon       = setSprite( 1136, 2, 160, 160 ),
    iconRect   = { x = 490, y = 64, w = 64, h = 64 },
    bgRect     = { x = 490, y = 64, w = 64, h = 92 },
    headerRect = { x = 490, y = 54, w = 64, h = 8 },
    textRect   = { x = 490, y = 128, w = 64, h = 28 },
}

style.MediaControl = function(label1, label2, label3)
    local css1 = style.prev
    local css2 = style.playPause
    local css3 = style.next
    local textUnderlay1, textLabel1, divider1 = SetLabel(label1, css1.textRect)
    local textUnderlay2, textLabel2, divider2  = SetLabel(label2, css2.textRect)
    local textUnderlay3, textLabel3, divider3  = SetLabel(label3, css3.textRect)
    local iconUnderlay1, iconImage1 = SetIcon(css1)
    local iconUnderlay2, iconImage2 = SetIcon(css2)
    local iconUnderlay3, iconImage3 = SetIcon(css3)
    return {
        SetHeader(css1),
        iconUnderlay1, iconImage1, textUnderlay1, textLabel1, divider1,
        SetHeader(css2),
        iconUnderlay2, iconImage2, textUnderlay2, textLabel2, divider2,
        SetHeader(css3),
        iconUnderlay3, iconImage3, textUnderlay3, textLabel3, divider3,
        SetVerticalLine(css2.iconRect),SetVerticalLine(css3.iconRect)
    }
end

style.illuminationDown = {
    icon       = setSprite( 1298, 2, 160, 160 ),
    iconRect   = { x = 564, y = 64, w = 64, h = 64 },
    bgRect     = { x = 564, y = 64, w = 64, h = 92 },
    headerRect = { x = 564, y = 54, w = 64, h = 8 },
    textRect   = { x = 564, y = 128, w = 64, h = 28 },
}

style.illuminationUp = {
    icon       = setSprite( 1460, 2, 160, 160 ),
    iconRect   = { x = 628, y = 64, w = 64, h = 64 },
    bgRect     = { x = 628, y = 64, w = 64, h = 92 },
    headerRect = { x = 628, y = 54, w = 64, h = 8 },
    textRect   = { x = 628, y = 128, w = 64, h = 28 },
}

style.Illumination = function(label1, label2)
    local css1 = style.illuminationDown
    local css2 = style.illuminationUp
    local textUnderlay1, textLabel1, divider1 = SetLabel(label1, css1.textRect)
    local textUnderlay2, textLabel2, divider2 = SetLabel(label2, css2.textRect)
    local iconUnderlay1, iconImage1 = SetIcon(css1)
    local iconUnderlay2, iconImage2 = SetIcon(css2)
    return {
        SetHeader(css1),
        iconUnderlay1,iconImage1,textUnderlay1, textLabel1, divider1,
        SetHeader(css2),
        iconUnderlay2,iconImage2,textUnderlay2, textLabel2, divider2,
        SetVerticalLine(css2.iconRect)

    }
end

return style