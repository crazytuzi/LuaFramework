local Lplus = require("Lplus")
local IBattleFeature = Lplus.Class("BattleFeature")
local CaptureTheFlagUtils = require("Main.CaptureTheFlag.CaptureTheFlagUtils")
local PlayType = require("consts.mzm.gsp.singlebattle.confbean.PlayType")
local def = IBattleFeature.define
def.field("number").playType = 0
def.final("=>", "table").Instance = function()
  return nil
end
local playLibCfg = {}
def.method("number", "=>", "boolean").IsActive = function(self, cfgId)
  if not playLibCfg[cfgId] then
    local battleCfg = CaptureTheFlagUtils.GetBattleCfg(cfgId)
    local playLib = CaptureTheFlagUtils.GetBattlePlays(battleCfg.playLibId)
    playLibCfg[cfgId] = playLib
  end
  if playLibCfg[cfgId][self.playType] then
    return true
  else
    return false
  end
end
def.virtual().Init = function(self)
end
def.virtual().Reset = function(self)
end
def.virtual().OnEnterBattle = function(self)
end
def.virtual("number").OnEnterStage = function(self, stage)
end
def.virtual().OnQuitBattle = function(self)
end
def.virtual().TickSecond = function(self)
end
def.virtual("=>", "string").GetExtraName = function(self)
  return ""
end
def.virtual("=>", "string").GetExtraSprite = function(self)
  return ""
end
def.virtual("userdata", "=>", "string").GetExtraData = function(self, roleId)
  return ""
end
def.virtual("userdata", "=>", "string").GetFinalData = function(self, roleId)
  return ""
end
def.virtual("function").IsStatisticsReady = function(self, func)
  func()
end
return IBattleFeature.Commit()
