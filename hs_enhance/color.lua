local color = {}

function color.SetByHex(hex, alpha)
    local r = tonumber(hex:sub(1, 2), 16) / 255
    local g = tonumber(hex:sub(3, 4), 16) / 255
    local b = tonumber(hex:sub(5, 6), 16) / 255
    return { red = r, green = g, blue = b, alpha = alpha or 1 }
end

return color