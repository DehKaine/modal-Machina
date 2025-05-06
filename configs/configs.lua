local json = require("hs.json")
-- 
local configsJsonPath = os.getenv("HOME") .. "/.hammerspoon/configs/configs.json"
local function loadConfig()
    local file = io.open(configsJsonPath,"r")
    if not file then return {} end
    local content = file:read("*a")
    file:close()
    return json.decode(content)
end

local configs = loadConfig()

return configs