local win_flow = {}

-- 使用 Bundle ID 或精准进程名，彻底解决名称不匹配导致的 300~500ms 延迟
local focus_map = {
	fc = "com.openai.chat",        -- ChatGPT
	fe = "com.eagle.app",          -- Eagle
	fg = "com.google.Chrome",      -- Google Chrome
	fG = "org.godotengine.godot",  -- Godot
	fi = "com.googlecode.iterm2",  -- iTerm2 (原 iTerm.app 匹配失败导致延迟)
	fI = "com.apple.finder",       -- Finder
	fo = "com.DanPristupov.Fork",  -- Fork
	fp = "Adobe Photoshop 2021",   -- Photoshop
	ft = "com.apple.Terminal",     -- Terminal (原 Terminal.app)
	fv = "com.microsoft.VSCode",   -- Visual Studio Code
	fw = "com.tencent.xinWeChat",  -- 微信 (原 WeChat.app 匹配失败导致延迟)
}

local function activateAndRestore(app)
	if not app then return end

	-- 1. 原生激活应用并把所有非最小化窗口带到最前端（极速，无 AX 遍历开销）
	app:activate(true)

	-- 2. 针对非 Finder 应用解最小化窗口
	-- Finder 包含大量系统桌面 AX 节点，遍历全量窗口极为耗时
	if app:name() ~= "Finder" then
		local wins = app:allWindows()
		for _, win in ipairs(wins) do
			if win:isMinimized() then
				win:unminimize()
				win:focus()
				break
			end
		end
	end
end

function win_flow.focusToAppByCmd(cmd)
	local hint = focus_map[cmd]
	if hint then
		-- 先尝试使用 Bundle ID 快速定位，若 hint 为非 Bundle ID 则退回 find
		local app = hs.application.get(hint) or hs.application.find(hint)
		if app then
			activateAndRestore(app)
		else
			-- 未运行时，优先使用 Bundle ID 启动，失败则回退到 launchOrFocus
			if not hs.application.launchOrFocusByBundleID(hint) then
				hs.application.launchOrFocus(hint)
			end
		end
	end
end

function win_flow.focusLastApp()
	hs.eventtap.event.newKeyEvent("cmd", true):post()
	hs.eventtap.event.newKeyEvent("tab", true):post()
	hs.eventtap.event.newKeyEvent("cmd", false):post()
	hs.eventtap.event.newKeyEvent("tab", false):post()
end

function win_flow.restoreFrontmostApp()
	local app = hs.application.frontmostApplication()
	if app then
		activateAndRestore(app)
	end
end

function win_flow.moveItermBetweenMacIpad()
	hs.osascript.applescript([[
		tell application "iTerm2" to activate
		tell application "System Events"
			tell process "iTerm2"
					click menu bar item "Window" of menu bar 1
					repeat 8 times
						key code 125
					end repeat
					key code 36
			end tell
		end tell
	]])
end

return win_flow
