local style = {}

style.center = function(x, y)
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

style.expand = function(x, y, w, h)
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