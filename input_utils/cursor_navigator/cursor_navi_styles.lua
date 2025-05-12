local style = {}

style.grid = {
    type = "rectangle",
    action = "stroke",
    innerLineColor = { red = 0.3, green = 0.7, blue = 1.0, alpha = 0.5 },
    outLineColor = { red = 0.3, green = 0.7, blue = 1.0, alpha = 1 },
    lineWidth = 1,
}

style.anchor = {
    fontColor = { alpha = 0.9, red = 0, green = 0, blue = 0 },
    fontName = "Monaco",
    fontSize = 16,
    bgColor = { alpha = 0.6, red = 1, green = 1, blue = 0 },
    lastPtColor = { alpha = 0.6, red = 1, green = 0.4, blue = 0.2 },
    radius = 2,
    padding = 4
}

style.crosshairCenter = function(x, y)
    local size = 10
    return {
        {
            type = "segments",
            action = "stroke",
            strokeColor = { red = 1, green = 1, blue = 1, alpha = 1 },
            strokeWidth = 3,
            coordinates = {
                { x = x - size, y = y },
                { x = x + size, y = y }
            }
        },
        {
            type = "segments",
            action = "stroke",
            strokeColor = { red = 1, green = 1, blue = 1, alpha = 1 },
            strokeWidth = 3,
            coordinates = {
                { x = x, y = y - size },
                { x = x, y = y + size }
            }
        }
    }
end

style.crosshairExpand = function(x, y, w, h)
    return {
        {
            type = "segments",
            action = "stroke",
            strokeColor = { red = 0.3, green = 0.7, blue = 1.0, alpha = 1 },
            strokeWidth = 1,
            coordinates = {
                { x = 0, y = y },
                { x = w, y = y }
            }
        },
        {
            type = "segments",
            action = "stroke",
            strokeColor = { red = 0.3, green = 0.7, blue = 1.0, alpha = 1 },
            strokeWidth = 1,
            coordinates = {
                { x = x, y = 0 },
                { x = x, y = h }
            }
        }
    }
end

return style