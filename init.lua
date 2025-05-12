-- configs
require("configs.configs")

-- vim
require("vim.vim_core")

-- input_utils
require("input_utils.cursor_navigator.cursor_navi_core")
require("input_utils.single_key")
require("input_utils.multi_keys")
require("input_utils.win_flow")
require("input_utils.media_controller")

-- overlay_utils
require("overlay_utils.memocho")

-- master event manager
local master_eventtap = require("master_eventtap")
master_eventtap.start()
