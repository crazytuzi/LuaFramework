local Lplus = require("Lplus")
local NPCTradeData = Lplus.Class("NPCTradeData")
local def = NPCTradeData.define
local instance
def.static("=>", NPCTradeData).Instance = function()
  if nil == instance then
    instance = NPCTradeData()
  end
  return instance
end
def.static("number", "=>", "table").GetStoreCfg = function(serviceId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_NPC_TRADE_CFG, serviceId)
  if record == nil then
    return nil
  end
  local ret = {}
  ret.shopName = record:GetStringValue("shopName")
  ret.artFontIconId = record:GetStringValue("artFontIconId")
  ret.priceType = record:GetIntValue("priceType")
  ret.maxBuyNum = record:GetIntValue("maxBuyNum")
  ret.itemList = {}
  local itemListStruct = record:GetStructValue("npcItemListStruct")
  local count = itemListStruct:GetVectorSize("itemList")
  for i = 1, count do
    local itemRecord = itemListStruct:GetVectorValueByIdx("itemList", i - 1)
    local itemId = itemRecord:GetIntValue("itemId")
    table.insert(ret.itemList, itemId)
  end
  return ret
end
def.static("number", "=>", "boolean").IsNPCShopId = function(serviceId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_NPC_TRADE_CFG, serviceId)
  if record == nil then
    return false
  else
    return true
  end
end
NPCTradeData.Commit()
return NPCTradeData
