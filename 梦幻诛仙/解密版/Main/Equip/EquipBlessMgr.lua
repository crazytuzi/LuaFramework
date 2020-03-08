local MODULE_NAME = (...)
local Lplus = require("Lplus")
local EquipBlessMgr = Lplus.Class(MODULE_NAME)
local EquipUtils = require("Main.Equip.EquipUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
local def = EquipBlessMgr.define
local instance
def.static("=>", EquipBlessMgr).Instance = function()
  if instance == nil then
    instance = EquipBlessMgr()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.equipmentbless.SUseEquipmentBlessItemSuccess", EquipBlessMgr.OnSUseEquipmentBlessItemSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.equipmentbless.SUseEquipmentBlessItemFail", EquipBlessMgr.OnSUseEquipmentBlessItemFail)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, EquipBlessMgr.OnFeatureOpenChange)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, EquipBlessMgr.OnRoleLvUp)
end
def.static("table").OnSUseEquipmentBlessItemSuccess = function(p)
  local effId = 0
  if 0 < p.success_count then
    effId = constant.CEquipmentBlessConsts.SUCCESS_SFX_ID
    Toast(string.format(textRes.Equip[505], p.used_count, p.success_count, p.added_exp))
  else
    effId = constant.CEquipmentBlessConsts.FAIL_SFX_ID
    Toast(string.format(textRes.Equip[506], p.used_count, p.success_count, p.added_exp))
  end
  local effres = _G.GetEffectRes(effId)
  if effres == nil then
    warn("effect not exist:" .. effId)
    return
  end
  require("Fx.GUIFxMan").Instance():Play(effres.path, "EquipBless", 0, 0, -1, false)
end
def.static("table").OnSUseEquipmentBlessItemFail = function(p)
  if p.reason > 0 and textRes.Equip.SUseEquipmentBlessItemFail[p.reason] then
    Toast(textRes.Equip.SUseEquipmentBlessItemFail[p.reason])
  else
    Toast(textRes.Equip.SUseEquipmentBlessItemFail[-1], p.reason)
  end
end
def.method("=>", "boolean").IsOpen = function(self)
  if not self:IsFeatureOpen() then
    return false
  end
  if not self:IsReachRequiredLevel() then
    return false
  end
  return true
end
def.method("=>", "boolean").CheckIsOpenAndToast = function(self)
  if not self:IsFeatureOpen() then
    Toast(textRes.Equip[500])
    return false
  end
  if not self:IsReachRequiredLevel() then
    Toast(string.format(textRes.Equip[501], 100))
    return false
  end
  return true
end
def.method("=>", "boolean").IsFeatureOpen = function(self)
  if _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_EQUIPMENT_BLESS) then
    return true
  end
  return false
end
def.method("=>", "boolean").HasNotify = function(self)
  if not self:IsOpen() then
    return false
  end
  return not self:HasViewedEquipBless()
end
local BlessKey = "EquipBless"
def.method("=>", "boolean").HasViewedEquipBless = function(self)
  if LuaPlayerPrefs.HasRoleKey(BlessKey) then
    return true
  end
  return false
end
def.method().MarkViewedEquipBless = function(self)
  LuaPlayerPrefs.SetRoleString(BlessKey, "1")
  Event.DispatchEvent(ModuleId.EQUIP, gmodule.notifyId.Equip.Equip_Bless_Notify_Change, nil)
end
def.method("=>", "boolean").IsReachRequiredLevel = function(self)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if not heroProp then
    return false
  end
  return heroProp.level >= constant.CEquipmentBlessConsts.OPEN_LEVEL
end
def.method("userdata", "number").UseSingleEquipmentBlessItem = function(self, uuid, itemId)
  if not self:CheckIsOpenAndToast() then
    return
  end
  local p = require("netio.protocol.mzm.gsp.equipmentbless.CUseSingleEquipmentBlessItemReq").new(uuid, itemId)
  gmodule.network.sendProtocol(p)
end
def.method("userdata", "number").UseMultipleEquipmentBlessItem = function(self, uuid, itemId)
  if not self:CheckIsOpenAndToast() then
    return
  end
  local p = require("netio.protocol.mzm.gsp.equipmentbless.CUseMultipleEquipmentBlessItemReq").new(uuid, itemId)
  gmodule.network.sendProtocol(p)
end
def.static("table", "table").OnFeatureOpenChange = function(params, context)
  local featureType = params.feature
  if featureType == require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_EQUIPMENT_BLESS then
    Event.DispatchEvent(ModuleId.EQUIP, gmodule.notifyId.Equip.Equip_Bless_Notify_Change, nil)
  end
end
def.static("table", "table").OnRoleLvUp = function(params, context)
  local HeroPropMgr = require("Main.Hero.mgr.HeroPropMgr").Instance()
  local heroProp = HeroPropMgr.heroProp
  local lastHeroProp = HeroPropMgr.lastHeroProp
  if heroProp == nil or lastHeroProp == nil then
    return
  end
  local myLv = heroProp.level
  local preLevel = lastHeroProp.level
  local unlockLevel = constant.CEquipmentBlessConsts.OPEN_LEVEL
  if myLv >= unlockLevel and preLevel < unlockLevel then
    Event.DispatchEvent(ModuleId.EQUIP, gmodule.notifyId.Equip.Equip_Bless_Notify_Change, nil)
  end
end
return EquipBlessMgr.Commit()
