local Color = require("hs_enhance.color")
--
local style = {}

local atlas = hs.image.imageFromPath("~/.HAMMERSPOON/ui/sprite/media_controller/media_controller_atlas.png")
local function setSprite( x, y, w, h )
    local slice = atlas:croppedCopy(hs.geometry.rect(x, y, w, h))
    return slice
end

local function SetLabel(textName, frame)
   return {
        type  = "text",
        text  = textName,
        textFont  = "Monaco",
        textSize  = 14,
        textColor = style.color.normalTextColor,
        textAlignment = "center",
        frame = frame or { x = 0, y = 0, w = 100, h = 20 }
    }
end

style.color = {
    normalTextColor     = Color.SetByHex("b1d1a5"),
    pressedTextColor    = { white = 1,   alpha = 1   },
    selectedTextColor   = Color.SetByHex("464646"),
    normalBgColor       = Color.SetByHex("464646"),
    pressedBgColor      = { white = 0.3, alpha = 0.8 },
    normalElementColor  = { white = 1,   alpha = 0.8 },
    pressedElementColor = { white = 1,   alpha = 1   }
}

style.bgPanel = {
    type = "image",
    image = setSprite(2, 164, 1784, 424),
    -- imageAlignment = "center",
    frame = { x = 0, y = 0, w = 720, h = 360 }
}

style.processBar = {
    
}

style.brightnessDown = {
    icon = setSprite(2, 2, 160, 160),
    bgRect   = { x = 0, y = 0, w = 32, h = 32 },
    pressedElementColor = {},
    normalBgColor  = {},
    pressedBgColor = {}
}

style.brightnessUp = {
    icon = setSprite(164, 2, 160, 160),
    bgRect   = { x = 0, y = 0, w = 32, h = 32 },
    pressedElementColor = {},
    normalBgColor  = {},
    pressedBgColor = {}
}

style.Brightness = function(label1, label2)
    local css1 = style.brightnessDown
    local css2 = style.brightnessUp
    return {
        {
            type = "rectangle",
            action = "fill",
            fillColor = css1.normalBgColor,
            frame = css1.bgRect
        },
        {
            type  = "image",
            image = css1.icon,
            imageFrame = css1.iconInfo.imageFrame,
            frame = css1.iconRect
        },
        SetLabel(
            label1,
            { x = 0, y = 0, w = 100, h = 20 }
        ),
        {
            type = "rectangle",
            action = "fill",
            fillColor = css2.normalBgColor,
            frame = css2.bgRect
        },
        {
            type  = "image",
            image = css2.iconInfo.image,
            imageFrame = css2.iconInfo.imageFrame,
            frame = css2.iconRect
        },
        SetLabel(
            label2,
            { x = 0, y = 0, w = 100, h = 20 }
        ),
    }
end

local soundDownSlice = setSprite( 326, 2, 160, 160)
style.soundDown = {
    iconInfo     = soundDownSlice,
    iconRect = { x = 0, y = 0, w = 32, h = 32 },
    bgRect   = { x = 0, y = 0, w = 32, h = 32 },
    pressedElementColor = {},
    normalBgColor  = {},
    pressedBgColor = {}
}

local soundUpSlice = setSprite( 488, 2, 160, 160)
style.soundUp = {
    iconInfo     = soundUpSlice,
    iconRect = { x = 0, y = 0, w = 32, h = 32 },
    bgRect   = { x = 0, y = 0, w = 32, h = 32 },
    pressedElementColor = {},
    normalBgColor  = {},
    pressedBgColor = {}
}

local muteSlice = setSprite( 650, 2, 160, 160)
style.mute = {
    iconInfo     = muteSlice,
    iconRect = { x = 0, y = 0, w = 32, h = 32 },
    bgRect   = { x = 0, y = 0, w = 32, h = 32 },
    pressedElementColor = {},
    normalBgColor  = {},
    pressedBgColor = {}
}

style.Sound = function(label1, label2, label3)
    local css1 = style.soundDown
    local css2 = style.soundUp
    local css3 = style.mute
    return {
        {
            type = "rectangle",
            action = "fill",
            fillColor = css1.normalBgColor,
            frame = css1.bgRect
        },
        {
            type  = "image",
            image = css1.iconInfo.image,
            imageFrame = css1.iconInfo.imageFrame,
            frame = css1.iconRect
        },
        SetLabel(
            label1,
            { x = 0, y = 0, w = 100, h = 20 }
        ),
        {
            type = "rectangle",
            action = "fill",
            fillColor = css2.normalBgColor,
            frame = css2.bgRect
        },
        {
            type  = "image",
            image = css2.iconInfo.image,
            imageFrame = css2.iconInfo.imageFrame,
            frame = css2.iconRect
        },
        SetLabel(
            label2,
            { x = 0, y = 0, w = 100, h = 20 }
        ),
        {
            type = "rectangle",
            action = "fill",
            fillColor = css3.normalBgColor,
            frame = css3.bgRect
        },
        {
            type  = "image",
            image = css3.iconInfo.image,
            imageFrame = css3.iconInfo.imageFrame,
            frame = css3.iconRect
        },
        SetLabel(
            label3,
            { x = 0, y = 0, w = 100, h = 20 }
        ),
    }
end

local prevSlice = setSprite( 812, 2, 160, 160)
style.prev = {
    iconInfo     = prevSlice,
    iconRect = { x = 0, y = 0, w = 32, h = 32 },
    bgRect   = { x = 0, y = 0, w = 32, h = 32 },
    pressedElementColor = {},
    normalBgColor  = {},
    pressedBgColor = {}
}

local playPauseSlice = setSprite( 974, 2, 160, 160)
style.playPause = {
    iconInfo     = playPauseSlice,
    iconRect = { x = 0, y = 0, w = 32, h = 32 },
    bgRect   = { x = 0, y = 0, w = 32, h = 32 },
    pressedElementColor = {},
    normalBgColor  = {},
    pressedBgColor = {}
}

local nextSlice = setSprite( 1136, 2, 160, 160)
style.next = {
    iconInfo     = nextSlice,
    iconRect = { x = 0, y = 0, w = 32, h = 32 },
    bgRect   = { x = 0, y = 0, w = 32, h = 32 },
    pressedElementColor = {},
    normalBgColor  = {},
    pressedBgColor = {}
}


style.MediaControl = function(label1, label2, label3)
    local css1 = style.playPause
    local css2 = style.next
    local css3 = style.prev
    return {
        {
            type = "rectangle",
            action = "fill",
            fillColor = css1.normalBgColor,
            frame = css1.bgRect
        },
        {
            type  = "image",
            image = css1.iconInfo.image,
            imageFrame = css1.iconInfo.imageFrame,
            frame = css1.iconRect
        },
        SetLabel(
            label1,
            { x = 0, y = 0, w = 100, h = 20 }
        ),
        {
            type = "rectangle",
            action = "fill",
            fillColor = css2.normalBgColor,
            frame = css2.bgRect
        },
        {
            type  = "image",
            image = css2.iconInfo.image,
            imageFrame = css2.iconInfo.imageFrame,
            frame = css2.iconRect
        },
        SetLabel(
            label2,
            { x = 0, y = 0, w = 100, h = 20 }
        ),
        {
            type = "rectangle",
            action = "fill",
            fillColor = css3.normalBgColor,
            frame = css3.bgRect
        },
        {
            type  = "image",
            image = css3.iconInfo.image,
            imageFrame = css3.iconInfo.imageFrame,
            frame = css3.iconRect
        },
        SetLabel(
            label3,
            { x = 0, y = 0, w = 100, h = 20 }
        ),
    }
end

local illuminationDownSlice = setSprite( 1298, 2, 160, 160)
style.illuminationDown = {
    iconInfo     = illuminationDownSlice,
    iconRect = { x = 0, y = 0, w = 32, h = 32 },
    bgRect   = { x = 0, y = 0, w = 32, h = 32 },
    pressedElementColor = {},
    normalBgColor  = {},
    pressedBgColor = {}
}

local illuminationUpSlice = setSprite( 1460, 2, 160, 160)
style.illuminationUp = {
    iconInfo     = illuminationUpSlice,
    iconRect = { x = 0, y = 0, w = 32, h = 32 },
    bgRect   = { x = 0, y = 0, w = 32, h = 32 },
    pressedElementColor = {},
    normalBgColor  = {},
    pressedBgColor = {}
}

style.Illumination = function(label1, label2)
    local css1 = style.illuminationDown
    local css2 = style.illuminationUp
    return {
        {
            type = "rectangle",
            action = "fill",
            fillColor = css1.normalBgColor,
            frame = css1.bgRect
        },
        {
            type  = "image",
            image = css1.iconInfo.image,
            imageFrame = css1.iconInfo.imageFrame,
            frame = css1.iconRect
        },
        SetLabel(
            label1,
            { x = 0, y = 0, w = 100, h = 20 }
        ),
        {
            type = "rectangle",
            action = "fill",
            fillColor = css2.normalBgColor,
            frame = css2.bgRect
        },
        {
            type  = "image",
            image = css2.iconInfo.image,
            imageFrame = css2.iconInfo.imageFrame,
            frame = css2.iconRect
        },
        SetLabel(
            label2,
            { x = 0, y = 0, w = 100, h = 20 }
        ),
    }
end

return style