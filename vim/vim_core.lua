local master_eventtap = require("master_eventtap")
local status = require("ui.statusbar")
local win_flow = require("input_utils.win_flow")
local vim_cmds = require("vim.vim_cmds")
--
local vim_core = {}
--
local command_map = vim_cmds.map
local single_exec_commands = vim_cmds.single_exec_cmds

local modal = hs.hotkey.modal.new({"alt"}, "space")

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

function vim_core.exitVim()
    modal:exit()
end

return vim_core