local Lplus = require("Lplus")
local DecorationMgr = Lplus.Class("DecorationMgr")
local def = DecorationMgr.define
local instance
local DecorationData = require("Main.GodWeapon.Decoration.data.DecorationData")
local DecorationProtocols = require("Main.GodWeapon.Decoration.DecorationProtocols")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = require("Main.Item.ItemModule")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
def.field("table")._data = nil
def.static("=>", DecorationMgr).Instance = function()
  if instance == nil then
    instance = DecorationMgr()
    instance._data = DecorationData()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, DecorationMgr.OnFeatureOpenChange)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, DecorationMgr.OnLeaveWorld)
  DecorationProtocols.Instance():Init()
end
def.static("=>", "boolean").IsFeatureOpen = function()
  local featureOpenModule = FeatureOpenListModule.Instance()
  local bFeatureOpen = featureOpenModule:CheckFeatureOpen(Feature.TYPE_SUPER_EQUIPMENT_WUSHI)
  return bFeatureOpen
end
def.static("number", "number", "number", "=>", "number").GetWeaponModelIdByWSCfgId = function(WSCfgId, occupation, gender)
  return DecorationMgr.GetData():GetWeaponIdByWSCfgId(WSCfgId, occupation, gender)
end
def.static("number", "number", "=>", "table").GetWuShiModelInfo = function(WSCfgId, modelId)
  local DecorationUtils = require("Main.GodWeapon.Decoration.DecorationUtils")
  if WSCfgId < 1 then
    return nil
  end
  local wsBasicCfg = DecorationUtils.GetWSBasicCfgById(WSCfgId)
  if wsBasicCfg ~= nil then
    local displayCfg = DecorationMgr.GetData():GetDisplayCfgByModelId(wsBasicCfg.displayTypeId, modelId)
    return displayCfg
  end
  return nil
end
def.static("=>", "table").GetData = function()
  local self = DecorationMgr.Instance()
  return self._data
end
def.static("table", "table", "=>", "boolean").ItemFilter = function(item, params)
  local itemBase = ItemUtils.GetItemBase(item.id)
  if itemBase.itemType == ItemType.WU_SHI_ITEM or itemBase.itemType == ItemType.WU_SHI_FRAGMENT_ITEM then
    return true
  end
  return false
end
def.static("=>", "boolean").IsShowRedDot = function()
  if not DecorationMgr.IsOwndGodWeapon() or not DecorationMgr.IsEquipGodWeapon() then
    return false
  end
  local data = DecorationMgr.GetData()
  local owndWSList = data:GetOwnedWSList() or {}
  for i = 1, #owndWSList do
    local owndWSInfo = owndWSList[i]
    if DecorationMgr.CanWSImprove(owndWSInfo.wuShiCfgId and owndWSInfo.wuShiCfgId or 0) then
      return true
    end
  end
  return false
end
def.static("number", "=>", "boolean").CanWSImprove = function(WSCfgId)
  local data = DecorationMgr.GetData()
  local itemIds = data:GetItemIdsByWSCfgId(WSCfgId)
  if itemIds ~= nil then
    for i = 1, #itemIds do
      local itemNum = ItemModule.Instance():GetItemCountById(itemIds[i])
      if itemNum > 0 then
        return true
      end
    end
  end
  return false
end
def.static("=>", "boolean").IsOwndGodWeapon = function()
  local myEquipList = require("Main.GodWeapon.JewelMgr").GetData():GetHeroGodWeapons() or {}
  return #myEquipList > 0
end
def.static("=>", "boolean").IsEquipGodWeapon = function()
  local myEquipList = require("Main.GodWeapon.JewelMgr").GetData():GetHeroGodWeapons() or {}
  local numEquips = #myEquipList
  local BagInfo = require("netio.protocol.mzm.gsp.item.BagInfo")
  local bEquipWeapon = false
  for i = 1, numEquips do
    local equipInfo = myEquipList[i]
    if equipInfo.wearPos == 0 and equipInfo.bEquiped then
      bEquipWeapon = true
    end
  end
  return bEquipWeapon
end
def.static("table", "table").OnFeatureOpenChange = function(p, c)
  if p.feature == Feature.TYPE_SUPER_EQUIPMENT_WUSHI then
    Event.DispatchEvent(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.GOD_WEAPON_FEATURE_CHANGE, nil)
  end
end
def.static("table", "table").OnLeaveWorld = function(p, c)
  local self = DecorationMgr.Instance()
  self._data = DecorationData()
end
def.static("table", "table").OnBagChange = function(p, c)
  Event.DispatchEvent(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.WS_IMPROVE_ITEM_CHG, nil)
end
return DecorationMgr.Commit()
