local vim_status = {}

local canvas
local hideTimer
local bar_height = 16
local padding_x = 12
local visible = false

local font = {
    name = "Monaco",
    size = 12,
    color = {0.8, 0.8, 0.8},
}

-- 创建/重新定位 状态栏
local function createCanvas()
    local screen = hs.mouse.getCurrentScreen()
    if not screen then
        screen = hs.screen.mainScreen()
    end

    local screenFrame = screen:fullFrame()
    local barFrame = {
        x = screenFrame.x,
        y = screenFrame.y + screenFrame.h - bar_height,
        w = screenFrame.w,
        h = bar_height,
    }

    if not canvas then
        canvas = hs.canvas.new(barFrame)
            :level("status")
            :behavior({"canJoinAllSpaces"})
        canvas[1] = { type = "rectangle", action = "fill", fillColor = {hex="#eceae8"},
            roundedRectRadii = {0,0,0,0} }
        canvas[2] = { type = "text", text = "", textFont = font.name, textSize = font.size,
                        textColor = {hex="#e77d30"}, textAlignment="left",
                        frame = { x = padding_x, y = 0, w = barFrame.w - 2*padding_x, h = bar_height } }
    else
        canvas:frame(barFrame)
    end
end

local function show(text)
    createCanvas()
    canvas[2].text = text

    if not visible then
        canvas:show()
        visible = true
    end

    if hideTimer then
        hideTimer:stop()
    end
end

local function flash(text,delay)
    show(text)
    if hideTimer then
        hideTimer:stop()
    end

    hideTimer = hs.timer.doAfter(delay, function()
        if canvas then
            canvas:hide()
            visible = false
        end
    end)
end

vim_status.show = show
vim_status.flash = flash
vim_status.hide = function()
    if canvas and visible then
        canvas:hide()
        visible = false
    end
end

return vim_status