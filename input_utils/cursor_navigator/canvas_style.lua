local style = {}

style.grid = {
    type = "rectangle",
    action = "stroke",
    innerLineColor = { red = 0.3, green = 0.7, blue = 1.0, alpha = 0.5 },
    outLineColor = { red = 0.3, green = 0.7, blue = 1.0, alpha = 1 },
    lineWidth = 1,
}

style.anchor = {
    normalColor = { alpha = 0.9, red = 0, green = 0, blue = 0 },
    underlayColor = { alpha = 0.6, red = 1, green = 1, blue = 0 },
    fontName = "Monaco",
    fontSize = 16,
    radius = 2,
    padding = 4
}

return style