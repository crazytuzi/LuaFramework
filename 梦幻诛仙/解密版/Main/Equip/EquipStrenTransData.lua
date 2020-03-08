local Lplus = require("Lplus")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local EquipStrenTransData = Lplus.Class("EquipStrenTransData")
local EquipUtils = require("Main.Equip.EquipUtils")
local def = EquipStrenTransData.define
local instance
def.field("table")._strenEquips = nil
def.field("table")._canWearEquips = nil
def.field("table")._notMatchEquips = nil
def.field("table")._transEquips = nil
def.field("table")._inheritEquips = nil
def.field("table")._effectEquips = nil
def.static("=>", EquipStrenTransData).Instance = function()
  if nil == instance then
    instance = EquipStrenTransData()
    instance._strenEquips = {}
    instance._canWearEquips = {}
    instance._notMatchEquips = {}
    instance._transEquips = {}
    instance._inheritEquips = {}
    instance._effectEquips = {}
  end
  return instance
end
def.method().Init = function(self)
  self._strenEquips = {}
  self._canWearEquips = {}
  self._notMatchEquips = {}
  self._transEquips = {}
  self._inheritEquips = {}
  local bagId = require("netio.protocol.mzm.gsp.item.BagInfo").BAG
  local eqpBagId = require("netio.protocol.mzm.gsp.item.BagInfo").EQUIPBAG
  local strenMinLv = EquipUtils.GetQiLingMinLv()
  self:FillEquips(eqpBagId)
  table.sort(self._strenEquips, function(a, b)
    return a.wearPos < b.wearPos
  end)
  table.sort(self._transEquips, function(a, b)
    return a.wearPos < b.wearPos
  end)
  table.sort(self._inheritEquips, function(a, b)
    return a.wearPos < b.wearPos
  end)
  self:FillEquips(bagId)
  table.sort(self._canWearEquips, function(a, b)
    return a.score > b.score
  end)
  for k, v in pairs(self._canWearEquips) do
    if strenMinLv <= v.useLevel then
      table.insert(self._strenEquips, v)
    end
    local itemBase = ItemUtils.GetItemBase(v.id)
    if #v.exproList ~= 0 and false == itemBase.isProprietary then
      table.insert(self._transEquips, v)
    end
    if false == itemBase.isProprietary then
      table.insert(self._inheritEquips, v)
    end
  end
  table.sort(self._notMatchEquips, function(a, b)
    return a.score > b.score
  end)
  for k, v in pairs(self._notMatchEquips) do
    if strenMinLv <= v.useLevel then
      table.insert(self._strenEquips, v)
    end
    local itemBase = ItemUtils.GetItemBase(v.id)
    if #v.exproList ~= 0 and false == itemBase.isProprietary then
      table.insert(self._transEquips, v)
    end
    if false == itemBase.isProprietary then
      table.insert(self._inheritEquips, v)
    end
  end
  self._notMatchEquips = {}
  self._canWearEquips = {}
end
def.method().InitStrenEquip = function(self)
  self._strenEquips = {}
  self._canWearEquips = {}
  self._notMatchEquips = {}
  local bagId = require("netio.protocol.mzm.gsp.item.BagInfo").BAG
  local eqpBagId = require("netio.protocol.mzm.gsp.item.BagInfo").EQUIPBAG
  local strenMinLv = EquipUtils.GetQiLingMinLv()
  self:FillEquips(eqpBagId)
  table.sort(self._strenEquips, function(a, b)
    return a.wearPos < b.wearPos
  end)
  self:FillEquips(bagId)
  table.sort(self._canWearEquips, function(a, b)
    return a.score > b.score
  end)
  for k, v in pairs(self._canWearEquips) do
    if strenMinLv <= v.useLevel then
      table.insert(self._strenEquips, v)
    end
  end
  table.sort(self._notMatchEquips, function(a, b)
    return a.score > b.score
  end)
  for k, v in pairs(self._notMatchEquips) do
    if strenMinLv <= v.useLevel then
      table.insert(self._strenEquips, v)
    end
  end
  self._notMatchEquips = {}
  self._canWearEquips = {}
end
def.method().InitTransEquip = function(self)
  self._canWearEquips = {}
  self._notMatchEquips = {}
  self._transEquips = {}
  local bagId = require("netio.protocol.mzm.gsp.item.BagInfo").BAG
  local eqpBagId = require("netio.protocol.mzm.gsp.item.BagInfo").EQUIPBAG
  self:FillEquips(eqpBagId)
  table.sort(self._transEquips, function(a, b)
    return a.wearPos < b.wearPos
  end)
  self:FillEquips(bagId)
  table.sort(self._canWearEquips, function(a, b)
    return a.score > b.score
  end)
  for k, v in pairs(self._canWearEquips) do
    local itemBase = ItemUtils.GetItemBase(v.id)
    if #v.exproList ~= 0 and false == itemBase.isProprietary then
      table.insert(self._transEquips, v)
    end
  end
  table.sort(self._notMatchEquips, function(a, b)
    return a.score > b.score
  end)
  for k, v in pairs(self._notMatchEquips) do
    local itemBase = ItemUtils.GetItemBase(v.id)
    if #v.exproList ~= 0 and false == itemBase.isProprietary then
      table.insert(self._transEquips, v)
    end
  end
  self._notMatchEquips = {}
  self._canWearEquips = {}
end
def.method().InitInheritEquip = function(self)
  self._canWearEquips = {}
  self._notMatchEquips = {}
  self._inheritEquips = {}
  local bagId = require("netio.protocol.mzm.gsp.item.BagInfo").BAG
  local eqpBagId = require("netio.protocol.mzm.gsp.item.BagInfo").EQUIPBAG
  self:FillEquips(eqpBagId)
  table.sort(self._inheritEquips, function(a, b)
    return a.wearPos < b.wearPos
  end)
  self:FillEquips(bagId)
  table.sort(self._canWearEquips, function(a, b)
    return a.score > b.score
  end)
  for k, v in pairs(self._canWearEquips) do
    local itemBase = ItemUtils.GetItemBase(v.id)
    if false == itemBase.isProprietary then
      table.insert(self._inheritEquips, v)
    end
  end
  table.sort(self._notMatchEquips, function(a, b)
    return a.score > b.score
  end)
  for k, v in pairs(self._notMatchEquips) do
    local itemBase = ItemUtils.GetItemBase(v.id)
    if false == itemBase.isProprietary then
      table.insert(self._inheritEquips, v)
    end
  end
  self._notMatchEquips = {}
  self._canWearEquips = {}
end
def.method("=>", "boolean").IsHaveEquipToStren = function(self)
  self:InitStrenEquip()
  if #self._strenEquips > 0 then
    return true
  else
    return false
  end
end
def.method("number").FillEquips = function(self, bagId)
  local bagInfo = ItemModule.Instance():GetItemsByBagId(bagId)
  if nil == bagInfo then
    return
  end
  local strenMinLv = EquipUtils.GetQiLingMinLv()
  local itemType = require("consts.mzm.gsp.item.confbean.ItemType")
  for key, itemInfo in pairs(bagInfo) do
    local itemInBagInfo = ItemUtils.GetItemBase(itemInfo.id)
    if nil ~= itemInBagInfo and itemType.EQUIP == itemInBagInfo.itemType then
      local equipInfo = {}
      equipInfo.bagId = bagId
      equipInfo.id = itemInfo.id
      equipInfo.name = itemInBagInfo.name
      equipInfo.useLevel = itemInBagInfo.useLevel
      equipInfo.typeName = itemInBagInfo.itemTypeName
      equipInfo.iconId = itemInBagInfo.icon
      equipInfo.key = key
      equipInfo.uuid = itemInfo.uuid[1]
      equipInfo.namecolor = itemInBagInfo.namecolor
      local equipBase = ItemUtils.GetEquipBase(itemInBagInfo.itemid)
      equipInfo.wearPos = equipBase.wearpos
      equipInfo.qilinTypeid = equipBase.qilinTypeid
      local score = EquipUtils.CalcEpuipScoreUtil(itemInfo)
      equipInfo.score = score
      equipInfo.exproList = itemInfo.exproList
      equipInfo.extraProps = itemInfo.extraProps
      equipInfo.extraMap = itemInfo.extraMap
      if require("netio.protocol.mzm.gsp.item.BagInfo").EQUIPBAG == bagId then
        equipInfo.bEquiped = true
        if strenMinLv <= equipInfo.useLevel then
          table.insert(self._strenEquips, equipInfo)
        end
        local itemBase = ItemUtils.GetItemBase(itemInfo.id)
        if #equipInfo.exproList ~= 0 and false == itemBase.isProprietary then
          table.insert(self._transEquips, equipInfo)
        end
        if false == itemBase.isProprietary then
          table.insert(self._inheritEquips, equipInfo)
        end
      else
        equipInfo.bEquiped = false
        local prop = require("Main.Hero.Interface").GetBasicHeroProp()
        local menpai = prop.occupation
        local sex = prop.gender
        if equipInfo.manpai == menpai and equipInfo.sex == sex then
          table.insert(self._canWearEquips, equipInfo)
        else
          table.insert(self._notMatchEquips, equipInfo)
        end
      end
    end
  end
end
def.method("=>", "table").GetStrenEquips = function(self)
  return self._strenEquips
end
def.method("=>", "table").GetTransEquips = function(self)
  return self._transEquips
end
def.method("=>", "table").GetInheritEquips = function(self)
  return self._inheritEquips
end
def.method("=>", "table").InitEffectEquips = function(self)
  self._effectEquips = {}
  local bagId = require("netio.protocol.mzm.gsp.item.BagInfo").BAG
  local eqpBagId = require("netio.protocol.mzm.gsp.item.BagInfo").EQUIPBAG
  local equipList = self:GetEffectEquipByBagId(eqpBagId)
  local comp = function(info1, info2)
    if info1.wearpos == info2.wearpos then
      if info1.useLevel == info2.useLevel then
        return info1.id < info2.id
      else
        return info1.useLevel > info2.useLevel
      end
    else
      return info1.wearpos < info2.wearpos
    end
  end
  table.sort(equipList, comp)
  self._effectEquips = equipList
  equipList = self:GetEffectEquipByBagId(bagId)
  table.sort(equipList, comp)
  for i, v in ipairs(equipList) do
    table.insert(self._effectEquips, v)
  end
  return self._effectEquips
end
def.method("=>", "table").GetEffectEquips = function(self)
  return self._effectEquips
end
def.method("number", "=>", "table").GetEffectEquipByBagId = function(self, bagId)
  local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
  local bagInfo = ItemModule.Instance():GetItemsByBagId(bagId)
  local equipList = {}
  if nil == bagInfo then
    return equipList
  end
  local strenMinLv = EquipUtils.GetQiLingMinLv()
  local itemType = require("consts.mzm.gsp.item.confbean.ItemType")
  for key, itemInfo in pairs(bagInfo) do
    local itemInBagInfo = ItemUtils.GetItemBase(itemInfo.id)
    if nil ~= itemInBagInfo and itemType.EQUIP == itemInBagInfo.itemType then
      local equipInfo = {}
      equipInfo.bagId = bagId
      equipInfo.id = itemInfo.id
      equipInfo.name = itemInBagInfo.name
      equipInfo.useLevel = itemInBagInfo.useLevel
      equipInfo.typeName = itemInBagInfo.itemTypeName
      equipInfo.iconId = itemInBagInfo.icon
      equipInfo.key = key
      equipInfo.uuid = itemInfo.uuid[1]
      equipInfo.namecolor = itemInBagInfo.namecolor
      local equipBase = ItemUtils.GetEquipBase(itemInBagInfo.itemid)
      equipInfo.wearPos = equipBase.wearpos
      equipInfo.qilinTypeid = equipBase.qilinTypeid
      local score = EquipUtils.CalcEpuipScoreUtil(itemInfo)
      equipInfo.score = score
      local equipSkill = itemInfo.extraMap[ItemXStoreType.EQUIP_SKILL]
      if equipSkill and equipSkill > 0 then
        if require("netio.protocol.mzm.gsp.item.BagInfo").EQUIPBAG == bagId then
          equipInfo.bEquiped = true
        else
          equipInfo.bEquiped = false
        end
        table.insert(equipList, equipInfo)
      end
    end
  end
  return equipList
end
EquipStrenTransData.Commit()
return EquipStrenTransData
