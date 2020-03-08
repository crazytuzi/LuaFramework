local Lplus = require("Lplus")
local SoaringUtils = Lplus.Class("SoaringUtils")
local def = SoaringUtils.define
local instance
def.static("=>", SoaringUtils).Instance = function()
  if instance == nil then
    instance = SoaringUtils()
  end
  return instance
end
def.static("number", "=>", "table").GetGangChallengeCfgInfoById = function(cfgId)
  local cfgInfo
  return cfgInfo
end
return SoaringUtils.Commit()
