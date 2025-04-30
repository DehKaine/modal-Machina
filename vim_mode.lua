local vim_mode = {}

local master_eventtap = require("master_eventtap")
local status = require("ui.statusbar")
local win_flow = require("input_utils.win_flow")
-- local cursor_navigator = require("input_utils.cursor_navigator")

local modal = hs.hotkey.modal.new({"ctrl"}, "'")

local cmdBuffer = ""
local prefixNumber = ""
local lastCommand = nil

local exitTimer = nil
local function resetExitTimer()
    if exitTimer then
        exitTimer:stop()
    end
    exitTimer = hs.timer.doAfter(10, function()
        status.flash("Vim Mode: Timeout", 1)
        hs.timer.doAfter(1, function()
            modal:exit()
        end)
    end)
end

local command_map = {
    -- save & close
    ["wq"] = function()
        hs.eventtap.keyStroke({"cmd"}, "s", 0)
        hs.eventtap.keyStroke({"cmd"}, "w", 0)
    end,
    -- restore Minized windows
    ["rw"] = function()
        win_flow.restoreFrontmostApp()
    end,
    -- copy current line
    ["yy"] = function()
        hs.eventtap.keyStroke({"cmd"}, "left", 0)
        hs.eventtap.keyStroke({"shift", "cmd"}, "right", 0)
        hs.eventtap.keyStroke({"cmd"}, "c", 0)
        hs.eventtap.keyStroke({"cmd"}, "v", 0)
    end,
    -- newline to next line 
    ["o"] = function()
        hs.eventtap.keyStroke({"cmd"}, "right", 0)
        hs.eventtap.keyStroke({}, "return", 0)
    end,
    -- newlint to previous line
    ["O"] = function()
        hs.eventtap.keyStroke({"cmd"}, "left", 0)
        hs.eventtap.keyStroke({}, "return", 0)
        hs.eventtap.keyStroke({}, "up", 0)
    end,
    -- paste to next line
    ["p"] = function()
        hs.eventtap.keyStroke({"cmd"}, "left", 0)
        hs.eventtap.keyStroke({"cmd"}, "right", 0)
        hs.eventtap.keyStroke({}, "return", 0)
        hs.timer.doAfter(0.1, function()
            hs.eventtap.keyStroke({"cmd"}, "v", 0)
        end)
    end,
    -- delete current line
    ["dd"] = function()
        hs.eventtap.keyStroke({"cmd"}, "left", 0)
        hs.eventtap.keyStroke({"shift", "cmd"}, "right", 0)
        hs.eventtap.keyStroke({"cmd"}, "c", 0)
        hs.eventtap.keyStroke({}, "forwarddelete", 0)
        hs.eventtap.keyStroke({}, "forwarddelete", 0)
    end,
    -- delete line forward from cursor
    ["df"] = function()
        hs.eventtap.keyStroke({"shift", "cmd"}, "right", 0)
        hs.eventtap.keyStroke({"cmd"}, "c", 0)
        hs.eventtap.keyStroke({}, "forwarddelete", 0)
        hs.eventtap.keyStroke({}, "forwarddelete", 0)
    end,
    -- focus app by cmd
    ["fw"] = function()
        win_flow.focusToAppByCmd("fw")
    end,
    ["fi"] = function()
        win_flow.focusToAppByCmd("fi")
    end,
    ["fe"] = function()
        win_flow.focusToAppByCmd("fe")
    end,
    ["fg"] = function()
        win_flow.focusToAppByCmd("fg")
    end,
    ["fc"] = function()
        win_flow.focusToAppByCmd("fc")
    end,
    ["fv"] = function()
        win_flow.focusToAppByCmd("fv")
    end,
    -- vim left
    ["h"] = function()
        hs.eventtap.keyStroke({}, "left", 0)
    end,
    -- vim down
    ["j"] = function()
        hs.eventtap.keyStroke({}, "down", 0)
    end,
    -- vim up
    ["k"] = function()
        hs.eventtap.keyStroke({}, "up", 0)
    end,
    -- vim right
    ["l"] = function()
        hs.eventtap.keyStroke({}, "right", 0)
    end,
    -- -- cursor_navigator
    -- ["cc"] = function()
    --     cursor_navigator.start()
    -- end,
    -- reload hammerspoon
    ["rhs"] = function ()
        print("Vim Mode: Reloading Hammerspoon")
        hs.timer.doAfter(0.2, function()
            hs.reload()
        end)
    end
}

-- 只执行一次的指令集合
local single_exec_commands = {"wq","yy","dd"}

local function is_single_exec_command(cmd)
    for _, v in ipairs(single_exec_commands) do
        if v == cmd then
            return true
        end
    end
    return false
end

-- 定义 handler 逻辑
local function vim_handler(event)
    local etype = event:getType()
    if etype ~= hs.eventtap.event.types.keyDown then
        return false -- 只关心按下事件
    end

    -- 取得本次按下的实际字符（可打印）
    local char = event:getCharacters(true)  -- true = 忽略修饰键影响、直接取字符
    if char == "." then
        if lastCommand and command_map[lastCommand] then
            local count = tonumber(prefixNumber) or 1
            if is_single_exec_command(lastCommand) then
                count = 1
            end
            for i = 1, count do
                command_map[lastCommand]()
            end
            status.flash("Vim Cmd Executed", 2)
            resetExitTimer()
        end
        cmdBuffer = ""
        prefixNumber = ""
        return true
    end

    local flags = event:getFlags()
    if flags.cmd or flags.alt or flags.ctrl then
        return false   -- 让带修饰键的组合键直接传递给系统
    end
    if not char or #char ~= 1 then
        -- 非可打印字符（如 Esc / Function 键），放行给 modal 自己处理
        return false
    end

    -- -------- 进入指令累积与匹配 --------
    -- 判断是否数字前缀（只有当 cmdBuffer 不是字母时才允许数字前缀）
    if tonumber(char) and not char:match("%a") then
        prefixNumber = prefixNumber .. char
        status.show("Vim Cmd: " .. prefixNumber .. cmdBuffer)
        return true
    end

    -- 只拦截英文字母；其余字符放行
    if not char:match("%a") then
        return false
    end

    -- 剔除未匹配的字符
    local newBuffer = cmdBuffer .. char
    local matched = false
    for pattern, _ in pairs(command_map) do
        if pattern:sub(1, #newBuffer) == newBuffer then
            matched = true
            break
        end
    end

    if matched then
        cmdBuffer = newBuffer
        status.show("Vim Cmd: " .. prefixNumber .. cmdBuffer)
    else
        -- 不处理
    end

    -- 处理指令
    for pattern, action in pairs(command_map) do
        if cmdBuffer == pattern then
            local count = tonumber(prefixNumber) or 1
            if is_single_exec_command(cmdBuffer) then
                count = 1
            end
            for i = 1, count do
                action()
            end
            lastCommand = pattern
            cmdBuffer = ""
            prefixNumber = ""
            status.show("Vim Cmd Executed. Waiting for input... ")
            resetExitTimer()
            break
        end
    end

    -- 缓冲过长保护
    if #cmdBuffer > 6 then
        cmdBuffer = ""
    end

    return true  -- 我们拦截了这个按键
end

function modal:entered()
    cmdBuffer = ""
    prefixNumber = ""
    status.show("Vim Mode: ON")
    master_eventtap.register(vim_handler) -- 注册到 master_eventtap
end

function modal:exited()
    status.hide()
    master_eventtap.unregister(vim_handler) -- 退出时注销
    if exitTimer then
        exitTimer:stop()
        exitTimer = nil
    end
end

modal:bind({}, "escape", function()
    status.flash("Vim Mode: OFF", 1)
    hs.timer.doAfter(1, function()
        modal:exit()
    end)
end)

function vim_mode.exitVim()
    modal:exit()
end

return vim_mode