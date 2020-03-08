local Lplus = require("Lplus")
local AircraftData = require("Main.Aircraft.data.AircraftData")
local AircraftProtocols = require("Main.Aircraft.AircraftProtocols")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local AircraftMgr = Lplus.Class("AircraftMgr")
local def = AircraftMgr.define
local instance
def.static("=>", AircraftMgr).Instance = function()
  if instance == nil then
    instance = AircraftMgr()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, AircraftMgr.OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, AircraftMgr.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, AircraftMgr.OnBagInfoSynchronized)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, AircraftMgr.OnHeroLevelUp)
  Event.RegisterEvent(ModuleId.AIRCRAFT, gmodule.notifyId.Aircraft.USE_AIRCRAFT_ITEM, AircraftMgr.OnUseAircraftItem)
  Event.RegisterEvent(ModuleId.AIRCRAFT, gmodule.notifyId.Aircraft.USE_AIRCRAFT_DYE_ITEM, AircraftMgr.OnUseAircraftDyeItem)
end
def.static("table", "table").OnFunctionOpenChange = function(param, context)
  if param.feature == ModuleFunSwitchInfo.TYPE_AIRCRAFT and IsFeatureOpen(ModuleFunSwitchInfo.TYPE_AIRCRAFT) then
    require("Main.Aircraft.AircraftModule").Instance():SetReddot(true)
  end
end
def.static("table", "table").OnLeaveWorld = function(param, context)
  require("Main.Aircraft.AircraftModule").Instance():SetReddot(false)
  AircraftData.Instance():OnLeaveWorld(param, context)
end
def.static("table", "table").OnBagInfoSynchronized = function(params, context)
end
def.static("table", "table").OnHeroLevelUp = function(params, context)
  local openLevel = constant.CFeijianConsts.fei_jian_open_level
  if openLevel <= params.level and openLevel > params.lastLevel then
    require("Main.Aircraft.AircraftModule").Instance():SetReddot(true)
  end
end
def.static("table", "table").OnUseAircraftItem = function(params, context)
  if _G.CheckCrossServerAndToast() then
    return false
  end
  if require("Main.Aircraft.AircraftModule").Instance():IsOpen(true) then
    local ItemModule = require("Main.Item.ItemModule")
    local itemInfo = ItemModule.Instance():GetItemByBagIdAndItemKey(params.bagId, params.itemKey)
    local uuid = itemInfo and itemInfo.uuid[1]
    if uuid then
      AircraftProtocols.SendCUseAircraftItem(uuid)
    else
      warn("[ERROR][AircraftMgr:OnUseAircraftItem] uuid nil for params.bagId, params.itemKey", params.bagId, params.itemKey)
    end
  end
end
def.static("table", "table").OnUseAircraftDyeItem = function(params, context)
  if _G.CheckCrossServerAndToast() then
    return false
  end
  if require("Main.Aircraft.AircraftModule").Instance():IsOpen(true) then
    local aircraftInfo = AircraftData.Instance():GetCurrentAircraftInfo()
    if aircraftInfo then
      require("Main.Aircraft.ui.AircraftDyePanel").ShowPanel(aircraftInfo)
    else
      require("Main.Aircraft.AircraftInterface").OpenAircraftPanel(0)
    end
  end
end
def.static("table", "table").OnClickMapFindpath = function(param, context)
end
AircraftMgr.Commit()
return AircraftMgr
