local Lplus = require("Lplus")
local TokenMallData = Lplus.Class("TokenMallData")
local def = TokenMallData.define
def.field("number").relatedActivityId = 0
def.field("number").tokenMallCfgId = 0
def.field("table").leftExchangeCount = nil
def.field("userdata").exchangeResetTime = nil
def.field("number").manualRefreshCount = 0
def.field("userdata").manualRefreshResetTime = nil
def.field("table").bannedItems = nil
def.method("table").RawSet = function(self, data)
  self:UpdateMallExchangeData(data.exchangeCountInfo)
  self:UpdateMallManualRefreshData(data.manualRefreshCountInfo)
  self:UpdateBannedItems(data.soldOutInfo)
end
def.method("number").SetTokenMallCfgId = function(self, cfgId)
  self.tokenMallCfgId = cfgId
end
def.method("=>", "number").GetRelatedActivityId = function(self)
  return self.relatedActivityId
end
def.method("number").SetRelatedActivityId = function(self, activityId)
  self.relatedActivityId = activityId
end
def.method("number", "=>", "number").GetItemCanBuyCount = function(self, itemId)
  return self.leftExchangeCount[itemId] or -1
end
def.method("number", "number").SetItemCanBuyCount = function(self, itemId, count)
  self.leftExchangeCount[itemId] = count
end
def.method("=>", "boolean").WillResetExchangeCount = function(self)
  return not Int64.eq(self.exchangeResetTime, 0)
end
def.method("=>", "boolean").NeedResetExchangeCount = function(self)
  local curTime = _G.GetServerTime()
  return Int64.eq(self.exchangeResetTime, curTime)
end
def.method().ResetExchangeCount = function(self)
  self.leftExchangeCount = {}
  self.exchangeResetTime = Int64.new(0)
end
def.method("table").UpdateMallExchangeData = function(self, data)
  self.leftExchangeCount = data.cfgId2available
  self.exchangeResetTime = data.exchangeCountResetTimeStamp
end
def.method("=>", "number").GetManualRefreshCount = function(self)
  return self.manualRefreshCount
end
def.method("=>", "number").GetMaualRefreshLeftTime = function(self)
  local curTime = _G.GetServerTime()
  local leftTime = self.manualRefreshResetTime - curTime
  if not Int64.lt(leftTime, 0) then
    return Int64.ToNumber(leftTime)
  else
    return -1
  end
end
def.method().ResetManualRefreshData = function(self)
  self.manualRefreshCount = 0
  self.manualRefreshResetTime = Int64.new(0)
end
def.method("table").UpdateMallManualRefreshData = function(self, data)
  self.manualRefreshCount = data.manualRefreshCount
  self.manualRefreshResetTime = data.manualRefreshCountResetTimeStamp
end
def.method("table").UpdateBannedItems = function(self, data)
  self.bannedItems = {}
  for i = 1, #data.goodsCfgIds do
    self.bannedItems[data.goodsCfgIds[i]] = 1
  end
end
def.method("number", "=>", "boolean").IsMallItemBanned = function(self, mallItemId)
  if self.bannedItems == nil then
    return false
  end
  return self.bannedItems[mallItemId] == 1
end
return TokenMallData.Commit()
