local Color = require("hs_enhance.color")
--
local style = {}

local atlas = hs.image.imageFromPath("~/.HAMMERSPOON/ui/sprite/media_controller/media_controller_atlas.png")
local function setSprite( x, y, w, h )
    local slice = atlas:croppedCopy(hs.geometry.rect(x, y, w, h))
    return slice
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
            frame = frame
        }
    return underlay, label
end

style.color = {
    normalTextColor     = Color.SetByHex("b1d1a5"),
    pressedTextColor    = Color.SetByHex("343434"),
    selectedTextColor   = Color.SetByHex("464646"),
    headerColor         = Color.SetByHex("343434"),
    normalBgColor       = Color.SetByHex("464646"),
    pressedBgColor      = Color.SetByHex("b1d1a5"),
    normalElementColor  = { white = 1,   alpha = 0.8 },
    pressedElementColor = { white = 1,   alpha = 1   },
    activeBarColor      = Color.SetByHex("b1d1a5"),
    inactiveBarColor    = Color.SetByHex("343434"),
    barUnderlayColor    = Color.SetByHex("272727"),
}

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
    local textUnder1, textLabel1 = SetLabel(label1, css1.textRect)
    local textUnder2, textLabel2 = SetLabel(label2, css2.textRect)
    return {
        {
            type = "rectangle",
            action = "fill",
            fillColor = style.color.barUnderlayColor,
            frame = css1.headerRect
        },
        {
            type = "rectangle",
            action = "fill",
            fillColor = style.color.normalBgColor,
            frame = css1.bgRect
        },
        {
            type  = "image",
            image = css1.icon,
            frame = css1.iconRect
        },
        textUnder1,
        textLabel1,
        {
            type = "rectangle",
            action = "fill",
            fillColor = style.color.barUnderlayColor,
            frame = css2.headerRect
        },
        {
            type = "rectangle",
            action = "fill",
            fillColor = style.color.normalBgColor,
            frame = css2.bgRect
        },
        {
            type  = "image",
            image = css2.icon,
            frame = css2.iconRect
        },
        textUnder2,
        textLabel2
    }
end

style.soundBar = { x = 160, y = 54, w = 128, h = 8 }

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
    icon       = setSprite( 650, 2, 160, 160 ),
    iconRect   = { x = 288, y = 64, w = 64, h = 64 },
    bgRect     = { x = 288, y = 64, w = 64, h = 92 },
    headerRect = { x = 288, y = 54, w = 64, h = 8 },
    textRect   = { x = 288, y = 128, w = 64, h = 28 },
}

style.Sound = function(label1, label2, label3)
    local css1 = style.soundDown
    local css2 = style.soundUp
    local css3 = style.mute
    return {
       {
            type = "rectangle",
            action = "fill",
            fillColor = style.color.barUnderlayColor,
            frame = css1.headerRect
        },
        {
            type = "rectangle",
            action = "fill",
            fillColor = style.color.normalBgColor,
            frame = css1.bgRect
        },
        {
            type  = "image",
            image = css1.icon,
            frame = css1.iconRect
        },
        SetLabel(
            label1,
            css1.textRect
        ),
        {
            type = "rectangle",
            action = "fill",
            fillColor = style.color.barUnderlayColor,
            frame = css2.headerRect
        },
        {
            type = "rectangle",
            action = "fill",
            fillColor = style.color.normalBgColor,
            frame = css2.bgRect
        },
        {
            type  = "image",
            image = css2.icon,
            frame = css2.iconRect
        },
        SetLabel(
            label2,
            css2.textRect
        ),
        {
            type = "rectangle",
            action = "fill",
            fillColor = style.color.barUnderlayColor,
            frame = css3.headerRect
        },
        {
            type = "rectangle",
            action = "fill",
            fillColor = style.color.normalBgColor,
            frame = css3.bgRect
        },
        {
            type  = "image",
            image = css3.icon,
            frame = css3.iconRect
        },
        SetLabel(
            label3,
            css3.textRect
        )
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
    return {
       {
            type = "rectangle",
            action = "fill",
            fillColor = style.color.headerColor,
            frame = css1.headerRect
        },
        {
            type = "rectangle",
            action = "fill",
            fillColor = style.color.normalBgColor,
            frame = css1.bgRect
        },
        {
            type  = "image",
            image = css1.icon,
            frame = css1.iconRect
        },
        SetLabel(
            label1,
            css1.textRect
        ),
        {
            type = "rectangle",
            action = "fill",
            fillColor = style.color.headerColor,
            frame = css2.headerRect
        },
        {
            type = "rectangle",
            action = "fill",
            fillColor = style.color.normalBgColor,
            frame = css2.bgRect
        },
        {
            type  = "image",
            image = css2.icon,
            frame = css2.iconRect
        },
        SetLabel(
            label2,
            css2.textRect
        ),
        {
            type = "rectangle",
            action = "fill",
            fillColor = style.color.headerColor,
            frame = css3.headerRect
        },
        {
            type = "rectangle",
            action = "fill",
            fillColor = style.color.normalBgColor,
            frame = css3.bgRect
        },
        {
            type  = "image",
            image = css3.icon,
            frame = css3.iconRect
        },
        SetLabel(
            label3,
            css3.textRect
        )
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
    return {
        {
            type = "rectangle",
            action = "fill",
            fillColor = style.color.headerColor,
            frame = css1.headerRect
        },
        {
            type = "rectangle",
            action = "fill",
            fillColor = style.color.normalBgColor,
            frame = css1.bgRect
        },
        {
            type  = "image",
            image = css1.icon,
            frame = css1.iconRect
        },
        SetLabel(
            label1,
            css1.textRect
        ),
        {
            type = "rectangle",
            action = "fill",
            fillColor = style.color.headerColor,
            frame = css2.headerRect
        },
        {
            type = "rectangle",
            action = "fill",
            fillColor = style.color.normalBgColor,
            frame = css2.bgRect
        },
        {
            type  = "image",
            image = css2.icon,
            frame = css2.iconRect
        },
        SetLabel(
            label2,
            css2.textRect
        )
    }
end

return style