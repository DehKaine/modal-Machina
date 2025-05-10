local style = {}

style.grid = {
    type = "rectangle",
    action = "stroke",
    strokeColor = { red = 0.3, green = 0.7, blue = 1.0, alpha = 1 },
    strokeWidth = 1,
}

style.anchorItem = {}

style.anchorFont = {
    name = "Monaco",
    size = 16,
    normalColor = { alpha = 0.7, red = 1, green = 1, blue = 1 },
    underlayColor = { alpha = 0.4, red = 1, green = 1, blue = 0 },
}

return style