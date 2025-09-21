local Indicator = require("ui.status_indicator.status_indicator")
local win_flow = require("input_utils.win_flow")
--
local vim_cmds = {}

vim_cmds.map = {
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
    ["sl"] = function()
        hs.eventtap.keyStroke({"ctrl", "cmd"}, "q", 0)
    end,
    -------------------------------------------- focus app by cmd
    ["ff"] = function()
				win_flow.focusLastApp()
    end,
    ["fw"] = function()
        win_flow.focusToAppByCmd("fw")
    end,
    ["ft"] = function()
        win_flow.focusToAppByCmd("ft")
    end,
    ["fi"] = function()
        win_flow.focusToAppByCmd("fi")
    end,
    ["fI"] = function()
        win_flow.focusToAppByCmd("fI")
    end,
    ["fo"] = function()
        win_flow.focusToAppByCmd("fo")
    end,
    ["fp"] = function()
        win_flow.focusToAppByCmd("fp")
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
    -------------------------------------------- vim direction
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
    -------------------------------------------- 
    ["bl"] = function()
        hs.eventtap.keyStroke({"cmd"}, "left", 0)
        hs.eventtap.keyStroke({"shift", "cmd"}, "right", 0)
        hs.eventtap.keyStroke({"cmd"}, "b", 0)
        hs.eventtap.keyStroke({}, "right", 0)
    end,
    -------------------------------------------- Leader Commands
    -- reload hammer spoon
    ["<L>r"] = function()
        Indicator.Vim.Update("Reload")
        print("Vim Mode: Reloading Hammerspoon")
        print("==========>  NEW MACHINA  ==========>")
        hs.timer.doAfter(0.2, function()
            hs.reload()
        end)
    end,
    -- reload hammer spoon2
    ["rhs"] = function ()
        Indicator.Vim.Update("Reload")
        print("Vim Mode: Reloading Hammerspoon")
        print("==========>  NEW MACHINA  ==========>")
        hs.timer.doAfter(0.2, function()
            hs.reload()
        end)
    end
}

vim_cmds.single_exec_cmds = {"wq","yy","dd"}

return vim_cmds
