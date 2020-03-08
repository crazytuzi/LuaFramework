local MODULE_NAME = (...)
local Lplus = require("Lplus")
local JewelData = Lplus.Class("JewelData")
local def = JewelData.define
local BagInfo = require("netio.protocol.mzm.gsp.item.BagInfo")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local JewelUtils = require("Main.GodWeapon.Jewel.JewelUtils")
def.field("table")._items = nil
def.const("table").RELATED_BAGS = {
  BagInfo.BAG,
  BagInfo.EQUIPBAG
}
def.method("table").SetBagItems = function(self, items)
  self._items = {}
  for itemKey, item in pairs(items) do
    table.insert(self._items, item)
  end
end
def.method("table").AddJewelItem = function(self, items)
  if items == nil then
    return
  end
  self._items = self._items or {}
  for _, v in pairs(items) do
    table.insert(self._items, v)
  end
end
def.method("=>", "table").GetAllItems = function(self)
  self._items = {}
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  local itemType = ItemType.SUPER_EQUIPMENT_JEWEL_ITEM
  local _, jewelItem = ItemModule.Instance():SearchOneItemByItemType(itemType)
  if jewelItem ~= nil then
    local bagId = ItemModule.Instance():GetBagIdByItemId(jewelItem.id)
    local items = ItemModule.Instance():GetItemsByItemType(bagId, itemType)
    for itemKey, item in pairs(items) do
      table.insert(self._items, item)
    end
  end
  return self._items
end
def.method("=>", "table").GetJewelBag = function(self)
  return ItemModule.Instance():GetItemsByBagId(BagInfo.SUPER_EQUIPMENT_JEWEL_BAG)
end
def.method("=>", "table")._getOcpEquipments = function(self)
  local occupation = _G.GetHeroProp().occupation or 0
  local heroProp = _G.GetHeroProp()
  local heroOccupation = heroProp.occupation
  local heroEquipments = gmodule.moduleMgr:GetModule(ModuleId.ITEM):GetHeroEquipments()
  if heroOccupation == occupation then
    return heroEquipments
  else
    local equipments = OcpEquipmentMgr.Instance():GetOccupationEquipments(occupation)
    return equipments
  end
end
def.method("=>", "table").GetHeroGodWeapons = function(self)
  if nil == JewelData.RELATED_BAGS or #JewelData.RELATED_BAGS <= 0 then
    return nil
  end
  local ItemUtils = require("Main.Item.ItemUtils")
  local ItemModule = require("Main.Item.ItemModule")
  local retData = {}
  for _, bagId in ipairs(JewelData.RELATED_BAGS) do
    local equips = ItemModule.Instance():GetItemsByBagId(bagId)
    local BreakOutUtils = require("Main.GodWeapon.BreakOut.BreakOutUtils")
    local EquipUtils = require("Main.Equip.EquipUtils")
    local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
    equips = equips or {}
    for k, itemInfo in pairs(equips) do
      local godWeaponStage = itemInfo.extraMap[ItemXStoreType.SUPER_EQUIPMENT_STAGE]
      if BreakOutUtils.IsItemSatisfyGodWeapon(itemInfo) and godWeaponStage ~= nil and godWeaponStage > 0 then
        local equipInfo = {}
        local itemBase = ItemUtils.GetItemBase(itemInfo.id)
        local equipBase = ItemUtils.GetEquipBase(itemBase.itemid)
        equipInfo.id = itemInfo.id
        equipInfo.uuid = itemInfo.uuid[1]
        equipInfo.bagId = bagId
        equipInfo.key = k
        equipInfo.extraMap = itemInfo.extraMap
        equipInfo.jewelMap = itemInfo.jewelMap
        equipInfo.icon = itemBase and itemBase.icon or 0
        equipInfo.namecolor = itemBase and itemBase.namecolor or 0
        equipInfo.bEquiped = BagInfo.EQUIPBAG == bagId
        equipInfo.score = EquipUtils.CalcEpuipScoreUtil(itemInfo)
        equipInfo.godWeaponStage = godWeaponStage and godWeaponStage or 0
        local godWeaponLevel = itemInfo.extraMap[ItemXStoreType.SUPER_EQUIPMENT_LEVEL]
        equipInfo.godWeaponLevel = godWeaponLevel and godWeaponLevel or 0
        equipInfo.realName = ItemUtils.GetItemName(itemInfo, itemBase)
        equipInfo.frameName = ItemUtils.GetItemFrame(itemInfo, itemBase)
        equipInfo.strenLevel = EquipUtils.GetEquipStrenLevel(equipInfo.bagId, equipInfo.key)
        equipInfo.typeName = itemBase and itemBase.itemTypeName or ""
        local equipBase = ItemUtils.GetEquipBase(equipInfo.id)
        equipInfo.wearPos = equipBase and equipBase.wearpos or 0
        table.insert(retData, equipInfo)
      end
    end
  end
  if retData and #retData > 0 then
    table.sort(retData, function(a, b)
      if a == nil then
        return true
      elseif b == nil then
        return false
      elseif a.bEquiped ~= b.bEquiped then
        return a.bEquiped
      elseif a.wearPos ~= b.wearPos then
        return a.wearPos < b.wearPos
      elseif a.score ~= b.score then
        return a.score > b.score
      else
        return Int64.lt(a.uuid, b.uuid)
      end
    end)
  end
  return retData
end
def.method("number", "=>", "table").GetBagJewelsByEquipType = function(self, equipType)
  local retData = {}
  local allJewels = self:GetAllItems()
  if allJewels == nil then
    return retData
  end
  for _, item in pairs(allJewels) do
    local jewelCfg = JewelUtils.GetJewelItemByItemId(item.id, false) or {}
    if jewelCfg.type == equipType then
      jewelCfg.number = item.number
      jewelCfg.id = item.id
      table.insert(retData, jewelCfg)
    end
  end
  return retData
end
def.method("table", "number", "=>", "number").GetEquipMaxLvByItemId = function(self, equips, itemId)
  local jewelCfg = JewelUtils.GetJewelItemByItemId(itemId, false)
  if jewelCfg == nil then
    return 0
  end
  local breakOutData = require("Main.GodWeapon.BreakOut.data.BreakOutData").Instance()
  for _, equipInfo in pairs(equips) do
    if jewelCfg.type == equipInfo.wearPos then
      return breakOutData:GetStageCfg(equipInfo.godWeaponStage).maxGemLevel
    end
  end
  return breakOutData:GetStageCfg(1).maxGemLevel
end
def.method("number", "=>", "number").GetEquipOpenedSlotNum = function(self, stage)
  local breakOutData = require("Main.GodWeapon.BreakOut.data.BreakOutData").Instance()
  if stage < 1 then
    return 0
  end
  return breakOutData:GetStageCfg(stage or 1).gemSlotNum
end
return JewelData.Commit()
