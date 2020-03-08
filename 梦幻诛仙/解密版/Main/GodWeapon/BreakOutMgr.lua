local Lplus = require("Lplus")
local BreakOutData = require("Main.GodWeapon.BreakOut.data.BreakOutData")
local BreakOutUtils = require("Main.GodWeapon.BreakOut.BreakOutUtils")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local BreakOutMgr = Lplus.Class("BreakOutMgr")
local def = BreakOutMgr.define
local instance
def.static("=>", BreakOutMgr).Instance = function()
  if instance == nil then
    instance = BreakOutMgr()
  end
  return instance
end
def.method().Init = function(self)
  local BreakOutProtocols = require("Main.GodWeapon.BreakOut.BreakOutProtocols")
  BreakOutProtocols.RegisterProtocols()
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, BreakOutMgr._OnLeaveWorld)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, BreakOutMgr._OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.HERO_CLICKMAP_FINDPATH, BreakOutMgr.OnClickMapFindpath)
end
def.method("boolean", "=>", "boolean").IsOpen = function(self, bToast)
  return require("Main.GodWeapon.GodWeaponModule").Instance().IsOpen(bToast)
end
def.static("table", "=>", "boolean").CheckEquipBreakOutReddot = function(equipInfo)
  return BreakOutUtils.IsEquipReadyForStageUp(equipInfo) or BreakOutUtils.IsEquipReadyForLevelUp(equipInfo)
end
def.method("=>", "boolean").NeedReddot = function(self)
  return false
end
def.static("table", "table")._OnLeaveWorld = function(param, context)
  BreakOutData.Instance():OnLeaveWorld(param, context)
end
def.static("table", "table")._OnFunctionOpenChange = function(param, context)
  if param.feature ~= ModuleFunSwitchInfo.TYPE_CROSS_BATTLE_SEASON_1 or false == param.open then
  else
  end
end
def.static("table", "table").OnClickMapFindpath = function(param, context)
end
BreakOutMgr.Commit()
return BreakOutMgr
