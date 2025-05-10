local style = {}

style.grid = {
    type = "rectangle",
    action = "stroke",
    strokeColor = { red = 0.3, green = 0.7, blue = 1.0, alpha = 1 },
    strokeWidth = 1,
}


style.anchor = {
    normalColor = { alpha = 0.7, red = 1, green = 1, blue = 1 },
    underlayColor = { alpha = 0.4, red = 1, green = 1, blue = 0 },
    fontName = "Monaco",
    fontSize = 16,
    radius = 4,
    padding = 6
}

return style