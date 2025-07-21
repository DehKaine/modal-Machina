local master_eventtap = require("master_eventtap")
local status = require("ui.statusbar")
local vim_cmds = require("vim.vim_cmds")
local Indicator = require("ui.status_indicator.status_indicator")
--
local vim_core = {}
--
local command_map = vim_cmds.map
local single_exec_commands = vim_cmds.single_exec_cmds

local modal = hs.hotkey.modal.new({"alt"}, "space")
--
local cmdBuffer = ""
local prefixNumber = ""
local lastCommand = nil
local lastCount = 1
local exitTimer = nil

local longPressThreshold = 0.2
local longPressStartTime = 0
local longPressedTime = nil

local longPressTrigger = hs.hotkey.bind({}, "§",
    function ()
        longPressedTime = nil
        longPressStartTime = hs.timer.secondsSinceEpoch()
        hs.timer.doAfter(longPressThreshold,function()
            if not longPressedTime then
                longPressedTime = hs.timer.secondsSinceEpoch() - longPressStartTime
                if longPressedTime >= longPressThreshold then
                    modal:enter()
                end
            end
        end)
    end,
    function ()
        longPressedTime = hs.timer.secondsSinceEpoch() - longPressStartTime
        if longPressedTime < longPressThreshold then
            hs.pasteboard.setContents("_")
            hs.eventtap.keyStroke({"cmd"},"v",0)
            longPressedTime = 0
            longPressStartTime = 0
            return
        elseif longPressedTime > longPressThreshold then
            longPressedTime = 0
            longPressStartTime = 0
            modal:exit()
        end
    end
)

local function resetExitTimer()
    if exitTimer then
        exitTimer:stop()
    end
    exitTimer = hs.timer.doAfter(8, function()
        -- status.flash("Vim Mode: Timeout", 1)
        Indicator.Vim.Update("Timeout")
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
            local count = lastCount or 1
            if is_single_exec_command(lastCommand) then
                count = 1
            end
            for i = 1, count do
                command_map[lastCommand]()
            end
            -- status.flash("Vim Cmd Executed", 2)
            Indicator.Vim.Executed()
            resetExitTimer()
        end
        cmdBuffer = ""
        prefixNumber = ""
        return true
    end

    local flags = event:getFlags()
    if flags.cmd or flags.alt or flags.ctrl then
        return false
    end

    -- 数字前缀处理（先于非字母检查与 leader）
    if tonumber(char) and not char:match("%a") then
        prefixNumber = prefixNumber .. char
        Indicator.Vim.Update(prefixNumber .. cmdBuffer)
        return true
    end

    -- Leader key: use space as leader when cmdBuffer is empty
    if char == " " then
        if cmdBuffer == "" then
            cmdBuffer = "<L>"
            Indicator.Vim.Update(cmdBuffer)
            return true
        else
            return false
        end
    end

    -- 只拦截英文字母；其余字符放行
    if not char:match("%a") then
        return false
    end

    -- -------- 进入指令累积与匹配 --------
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
        -- status.show("Vim Cmd: " .. prefixNumber .. cmdBuffer)
        Indicator.Vim.Update(prefixNumber .. cmdBuffer)
    else
        --
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
            lastCount = count
            cmdBuffer = ""
            prefixNumber = ""
            Indicator.Vim.Executed()
            -- status.show("Vim Cmd Executed. Waiting for input... ")
            resetExitTimer()
            break
        end
    end

    if #cmdBuffer > 6 then
        cmdBuffer = ""
    end

    return true
end

function modal:entered()
    cmdBuffer = ""
    prefixNumber = ""
    Indicator.HideMachinaIcon()
    Indicator.Vim.Show()
    -- status.show("Vim Mode: ON")
    master_eventtap.register(vim_handler)
end

function modal:exited()
    -- status.hide()
    Indicator.Vim.Close()
    Indicator.ShowMachinaIcon()
    master_eventtap.unregister(vim_handler)
    if exitTimer then
        exitTimer:stop()
        exitTimer = nil
    end
end

modal:bind({}, "escape", function()
    -- status.flash("Vim Mode: OFF", 1)
    Indicator.Vim.Update("Exiting")
    hs.timer.doAfter(1, function()
        modal:exit()
    end)
end)

function vim_core.exitVim()
    modal:exit()
end

return vim_core