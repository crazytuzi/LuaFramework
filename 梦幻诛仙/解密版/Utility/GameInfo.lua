local Lplus = require("Lplus")
local TableProxy = require("Utility.TableProxy")
local _G = _G
local GameInfo = TableProxy.createEnvClass()
do
  local globals = {
    "assert",
    "error",
    "ipairs",
    "next",
    "pairs",
    "pcall",
    "print",
    "warn",
    "select",
    "tonumber",
    "tostring",
    "type",
    "unpack",
    "xpcall",
    "math",
    "string",
    "table"
  }
  for i = 1, #globals do
    local name = globals[i]
    GameInfo.set(name, _G[name])
  end
end
return GameInfo
