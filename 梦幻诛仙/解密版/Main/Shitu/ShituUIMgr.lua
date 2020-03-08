local Lplus = require("Lplus")
local ShituUIMgr = Lplus.Class("ShituUIMgr")
local ShituUtils = require("Main.Shitu.ShituUtils")
local ShituData = Lplus.ForwardDeclare("ShituData")
local ShituModule = Lplus.ForwardDeclare("ShituModule")
local def = ShituUIMgr.define
local instance
def.static("=>", ShituUIMgr).Instance = function()
  if instance == nil then
    instance = ShituUIMgr()
  end
  return instance
end
def.method("=>", "boolean").HasNotify = function(self)
  return self:HasNewChushiAwardNotify() or self:HasPayRespectNotify()
end
def.method("=>", "boolean").HasNewChushiAwardNotify = function(self)
  local awardData = ShituUtils.GetChushiAwardCfg()
  local awardCount = #awardData
  local shituData = ShituData.Instance()
  local chushiApprenticeNum = shituData:GetChushiApprenticeCount()
  for i = 1, awardCount do
    if chushiApprenticeNum >= awardData[i].chuShiApprenticeNum and not shituData:HasReceiveAward(awardData[i].cfgId) then
      return true
    end
  end
  return false
end
def.method("=>", "boolean").HasPayRespectNotify = function(self)
  if not ShituModule.IsQingAnFunctionOpen() then
    return false
  end
  local shituData = ShituData.Instance()
  return shituData:HasPayRespectTimes()
end
ShituUIMgr.Commit()
return ShituUIMgr
