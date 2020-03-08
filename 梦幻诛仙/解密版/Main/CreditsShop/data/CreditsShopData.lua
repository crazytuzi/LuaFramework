local Lplus = require("Lplus")
local CreditsShopUtility = require("Main.CreditsShop.CreditsShopUtility")
local CreditsShopData = Lplus.Class("CreditsShopData")
local def = CreditsShopData.define
local instance
def.field("table").typesList = nil
def.field("table").typeItemsList = nil
def.static("=>", CreditsShopData).Instance = function()
  if nil == instance then
    instance = CreditsShopData()
  end
  return instance
end
def.method().InitCreditType = function(self)
  local invalidType = {}
  local TokenType = require("consts.mzm.gsp.item.confbean.TokenType")
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_LADDER) then
    invalidType[TokenType.LADDER_SCORE] = true
  end
  self.typesList = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_TOKEN_TYPE)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local tokenType = DynamicRecord.GetIntValue(entry, "tokenType")
    if not invalidType[tokenType] then
      local name = DynamicRecord.GetStringValue(entry, "name")
      local sort = DynamicRecord.GetIntValue(entry, "sort")
      local iconId = DynamicRecord.GetStringValue(entry, "tipIconId")
      table.insert(self.typesList, {
        type = tokenType,
        name = name,
        sort = sort,
        iconId = iconId
      })
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  table.sort(self.typesList, function(a, b)
    return a.sort < b.sort
  end)
end
def.method("number", "=>", "string").GetCreditTypeName = function(self, type)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TOKEN_TYPE, type)
  if record == nil then
    warn("GetCreditTypeName nil", key)
    return textRes.Mall[8]
  end
  local name = record:GetStringValue("name")
  return name or textRes.Mall[8]
end
def.method().InitCreditItems = function(self)
  self.typeItemsList = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_OCCUPATION_CHALLENGE_ITEM_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local exchangeType = DynamicRecord.GetIntValue(entry, "exchangeType")
    local itemid = DynamicRecord.GetIntValue(entry, "itemid")
    local price = DynamicRecord.GetIntValue(entry, "price")
    if self.typeItemsList[exchangeType] == nil then
      self.typeItemsList[exchangeType] = {}
    end
    table.insert(self.typeItemsList[exchangeType], {itemId = itemid, price = price})
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  local remove = {}
  for k, v in ipairs(self.typesList) do
    if self.typeItemsList[v.type] == nil then
      table.insert(remove, k)
    end
  end
  for i = #remove, 1, -1 do
    table.remove(self.typesList, remove[i])
  end
end
def.method("=>", "table").GetCreditType = function(self)
  return self.typesList
end
def.method("number", "=>", "table").GetCreditItems = function(self, type)
  return self.typeItemsList[type]
end
def.method("number", "number", "=>", "number").GetItemPrice = function(self, type, itemId)
  local list = self.typeItemsList[type]
  if list ~= nil then
    for k, v in pairs(list) do
      if v.itemId == itemId then
        return v.price
      end
    end
    return 0
  else
    return 0
  end
end
def.method("number", "=>", "string").GetTypeIconId = function(self, type)
  for k, v in pairs(self.typesList) do
    if v.type == type then
      return v.iconId
    end
  end
  return ""
end
return CreditsShopData.Commit()
