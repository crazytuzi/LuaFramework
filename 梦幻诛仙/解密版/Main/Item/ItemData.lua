local Lplus = require("Lplus")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemData = Lplus.Class("ItemData")
local def = ItemData.define
local _instance
def.field("table")._itemData = nil
def.field("table")._money = nil
def.field("table")._yuanbao = nil
def.field("table")._credits = nil
def.static("=>", ItemData).Instance = function()
  if _instance == nil then
    _instance = ItemData()
    _instance._itemData = {}
    _instance._money = {}
    _instance._yuanbao = {}
    _instance._credits = {}
  end
  return _instance
end
def.method().Clear = function(self)
  self._itemData = {}
  self._money = {}
  self._yuanbao = {}
  self._credits = {}
end
def.method("number", "userdata").SetCredits = function(self, type, num)
  self._credits[type] = num
end
def.method("number", "=>", "userdata").GetCredits = function(self, type)
  if self._credits[type] ~= nil then
    return self._credits[type]
  end
  return nil
end
def.method("number", "userdata").SetYuanbao = function(self, type, num)
  self._yuanbao[type] = num
end
def.method("number", "=>", "userdata").GetYuanbao = function(self, type)
  if self._yuanbao[type] ~= nil then
    return self._yuanbao[type]
  end
  return Int64.new(0)
end
def.method("number", "userdata").SetMoney = function(self, type, num)
  self._money[type] = num
end
def.method("number", "=>", "userdata").GetMoney = function(self, type)
  if self._money[type] ~= nil then
    return self._money[type]
  end
  return nil
end
def.method("number", "number", "string").SetBag = function(self, bagId, cap, name)
  if self._itemData[bagId] == nil then
    if cap > 0 and name ~= nil then
      local bag = {}
      bag.name = name ~= "" and name or tostring(bagId)
      bag.cap = cap > 0 and cap or 0
      bag.items = {}
      self._itemData[bagId] = bag
    end
  else
    if cap > 0 then
      self._itemData[bagId].cap = cap
    end
    if name ~= nil then
      self._itemData[bagId].name = name
    end
  end
end
def.method("number", "=>", "table").GetBag = function(self, bagId)
  if self._itemData[bagId] == nil then
    return {}
  else
    return self._itemData[bagId].items
  end
end
def.method("number", "=>", "table").GetBag2 = function(self, bagId)
  return self._itemData[bagId]
end
def.method("number", "=>", "number").GetBagCapacity = function(self, bagId)
  if self._itemData[bagId] == nil then
    return 0
  else
    return self._itemData[bagId].cap
  end
end
def.method("number", "number", "=>", "table").GetItem = function(self, bagId, itemKey)
  if self._itemData[bagId] == nil then
    return nil
  end
  local bag = self._itemData[bagId].items
  if bag ~= nil then
    return bag[itemKey]
  else
    return nil
  end
end
def.method("number", "number", "=>", "number").GetNumberByItemId = function(self, bagId, itemId)
  return self:GetNumberByItemIdIgnoreTimeEffect(bagId, itemId, true)
end
def.method("number", "number", "boolean", "=>", "number").GetNumberByItemIdIgnoreTimeEffect = function(self, bagId, itemId, ignore)
  if self._itemData[bagId] == nil then
    return -1
  end
  local count = 0
  local bag = self._itemData[bagId].items
  for k, v in pairs(bag) do
    if v.id == itemId and (ignore or ItemUtils.IsItemDuringEffectTime(v)) then
      count = count + v.number
    end
  end
  return count
end
def.method("number", "number", "number", "table", "=>", "table", "number").GetItemUUIDsByItemId = function(self, bagId, itemId, needCount, UUIDs)
  if self._itemData[bagId] == nil then
    return nil
  end
  local retCount = 0
  UUIDs = UUIDs or {}
  local bag = self._itemData[bagId].items
  local GiveoutItemBean = require("netio.protocol.mzm.gsp.task.GiveoutItemBean")
  for k, v in pairs(bag) do
    if v.id == itemId then
      local tb = GiveoutItemBean.new()
      tb.uuid = v.uuid[1]
      tb.num = math.min(needCount - retCount, v.number)
      table.insert(UUIDs, tb)
      retCount = retCount + tb.num
      if needCount > 0 and needCount <= retCount then
        break
      end
    end
  end
  return UUIDs, retCount
end
def.method("number", "number", "=>", "number").GetNumByItemType = function(self, bagId, itemType)
  return self:GetNumByItemTypeIgnoreTimeEffect(bagId, itemType, true)
end
def.method("number", "number", "boolean", "=>", "number").GetNumByItemTypeIgnoreTimeEffect = function(self, bagId, itemType, ignore)
  if self._itemData[bagId] == nil then
    return nil
  end
  local bag = self._itemData[bagId].items
  local count = 0
  if bag ~= nil then
    for itemKey, item in pairs(bag) do
      local itembase = ItemUtils.GetItemBase(item.id)
      if itembase.itemType == itemType and (ignore or ItemUtils.IsItemDuringEffectTime(item)) then
        count = count + item.number
      end
    end
  end
  return count
end
def.method("number", "number", "=>", "table").GetItemsByItemType = function(self, bagId, itemType)
  return self:GetItemsByItemTypeIgnoreTimeEffect(bagId, itemType, true)
end
def.method("number", "number", "boolean", "=>", "table").GetItemsByItemTypeIgnoreTimeEffect = function(self, bagId, itemType, ignore)
  if self._itemData[bagId] == nil then
    return nil
  end
  local bag = self._itemData[bagId].items
  local items = {}
  if bag ~= nil then
    for itemKey, item in pairs(bag) do
      local itembase = ItemUtils.GetItemBase(item.id)
      if itembase.itemType == itemType and (ignore or ItemUtils.IsItemDuringEffectTime(item)) then
        items[itemKey] = item
      end
    end
  end
  return items
end
def.method("number", "number", "=>", "table").GetItemsByItemID = function(self, bagId, itemID)
  return self:GetItemsByItemIDIgnoreTimeEffect(bagId, itemID, true)
end
def.method("number", "number", "boolean", "=>", "table").GetItemsByItemIDIgnoreTimeEffect = function(self, bagId, itemID, ignore)
  if self._itemData[bagId] == nil then
    return nil
  end
  local bag = self._itemData[bagId].items
  local items = {}
  if bag ~= nil then
    for itemKey, item in pairs(bag) do
      if item.id == itemID and (ignore or ItemUtils.IsItemDuringEffectTime(item)) then
        items[itemKey] = item
      end
    end
  end
  return items
end
def.method("number", "table", "=>", "table").GetItemsByItemIds = function(self, bagId, ids)
  if self._itemData[bagId] == nil then
    return nil
  end
  local bag = self._itemData[bagId].items
  local items = {}
  if bag ~= nil then
    for itemKey, item in pairs(bag) do
      if ids[item.id] then
        items[itemKey] = item
      end
    end
  end
  return items
end
def.method("number", "number", "=>", "number", "table").SelectOneItemByItemId = function(self, bagId, itemId)
  if self._itemData[bagId] == nil then
    return -1, nil
  end
  local bag = self._itemData[bagId].items
  if bag ~= nil then
    for itemKey, item in pairs(bag) do
      if item.id == itemId then
        return itemKey, item
      end
    end
  end
  return -1, nil
end
def.method("number", "number", "=>", "number", "table").SelectOneItemByItemType = function(self, bagId, itemType)
  if self._itemData[bagId] == nil then
    return -1, nil
  end
  local bag = self._itemData[bagId].items
  if bag ~= nil then
    for itemKey, item in pairs(bag) do
      local itembase = ItemUtils.GetItemBase(item.id)
      if itembase.itemType == itemType then
        return itemKey, item
      end
    end
  end
  return -1, nil
end
def.method("number", "number", "=>", "number", "table").GetItemByPosition = function(self, bagId, position)
  if self._itemData[bagId] == nil then
    return -1, nil
  end
  local bag = self._itemData[bagId].items
  for k, v in pairs(bag) do
    if v.position == position then
      return k, v
    end
  end
  return -1, nil
end
def.method("number", "=>", "table").GetBrokenEquipsByBagID = function(self, bagId)
  if self._itemData[bagId] == nil then
    return {}
  end
  local bag = self._itemData[bagId].items
  local data = {}
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
  for _, v in pairs(bag) do
    local itemId = v.id
    local itemBase = ItemUtils.GetItemBase(itemId)
    if itemBase.itemType == ItemType.EQUIP then
      local equipBase = ItemUtils.GetEquipBase(itemBase.itemid)
      local equipFullDurable = equipBase.usePoint
      local usePoint = v.extraMap[ItemXStoreType.USE_POINT_VALUE]
      if equipFullDurable > usePoint then
        table.insert(data, v)
      end
    end
  end
  return data
end
def.method("number", "number", "number", "number", "number", "userdata", "number", "number", "table", "table", "table", "table", "table", "table", "table", "table").SetItem = function(self, bagId, itemKey, id, position, number, timeout, unlocktime, flag, extraMap, exproList, uuid, fumoProList, extraProps, extraInfoMap, super_equipment_cost_bean, jewelMap)
  if self._itemData[bagId] == nil then
    return
  end
  local bag = self._itemData[bagId].items
  if bag ~= nil then
    bag[itemKey] = {
      id = id,
      position = position,
      number = number,
      timeout = timeout,
      unlocktime = unlocktime,
      flag = flag,
      extraMap = extraMap,
      exproList = exproList,
      uuid = uuid,
      fumoProList = fumoProList,
      itemKey = itemKey,
      appellationId = 0,
      titleId = 0,
      extraProps = extraProps,
      extraInfoMap = extraInfoMap,
      super_equipment_cost_bean = super_equipment_cost_bean,
      jewelMap = jewelMap
    }
  else
    warn("I don't have bag ", bagId)
  end
end
def.method("number", "number").RemoveItem = function(self, bagId, itemKey)
  if self._itemData[bagId] == nil then
    return
  end
  local bag = self._itemData[bagId].items
  if bag ~= nil then
    bag[itemKey] = nil
  else
    warn("I don't have bag ", bagId)
  end
end
def.method("number").ClearBag = function(self, bagId)
  if bagId == 0 then
    self._itemData = {}
  else
    self._itemData[bagId] = {}
  end
end
def.method("number", "=>", "number").GetBagSize = function(self, bagId)
  local bag = self._itemData[bagId]
  if bag == nil then
    return 0
  end
  local bagItems = bag.items
  if bagItems == nil then
    return 0
  end
  local count = 0
  for k, v in pairs(bagItems) do
    count = count + 1
  end
  return count
end
def.method("number", "=>", "boolean").IsFull = function(self, bagId)
  local size = self:GetBagSize(bagId)
  return size >= self._itemData[bagId].cap
end
def.method("number", "number", "number", "=>", "table").FiltrateItems = function(self, bagId, siftID, needCount)
  local bag = self._itemData[bagId].items
  if bag == nil then
    return nil
  end
  local ret = {}
  local itemSiftCfg = ItemUtils.GetItemFilterCfg(siftID)
  local count = 0
  if bag ~= nil then
    for itemKey, item in pairs(bag) do
      local itembase = ItemUtils.GetItemBase(item.id)
      if ItemUtils.FiltrateAItem(itembase, itemSiftCfg) == true then
        for cc = 1, item.number do
          local r = {
            id = item.id,
            position = item.position,
            itemKey = item.itemKey,
            uuid = item.uuid[1],
            itemBase = itembase
          }
          table.insert(ret, r)
          if needCount > 0 and needCount <= #ret then
            break
          end
        end
        if needCount > 0 and needCount <= #ret then
          break
        end
      end
    end
  end
  return ret
end
ItemData.Commit()
return ItemData
