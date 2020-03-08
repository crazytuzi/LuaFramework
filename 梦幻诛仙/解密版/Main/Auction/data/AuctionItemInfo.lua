local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local AuctionItemInfo = Lplus.Class(CUR_CLASS_NAME)
local def = AuctionItemInfo.define
def.field("number").activityId = 0
def.field("number").round = 0
def.field("number").auctionItemId = 0
def.field("number").bidderCount = 0
def.field("userdata").maxBidPrice = nil
def.field("string").bidderRoleName = ""
def.field("userdata").bidderRoleId = nil
def.field("number").bidEndTimeStamp = 0
def.final("number", "number", "table", "=>", AuctionItemInfo).New = function(activityId, round, itemInfo)
  if itemInfo == nil then
    return nil
  end
  local auctionItemInfo = AuctionItemInfo()
  auctionItemInfo.activityId = activityId
  auctionItemInfo.round = round
  auctionItemInfo:SyncItemInfo(itemInfo)
  return auctionItemInfo
end
def.method("=>", "number").GetCountDown = function(self)
  local curTime = _G.GetServerTime()
  return math.max(self.bidEndTimeStamp - curTime, 0)
end
def.method("=>", "number").GetItemId = function(self)
  local auctionItemCfg = require("Main.Auction.data.AuctionData").Instance():GetAuctionItemCfg(self.auctionItemId)
  return auctionItemCfg and auctionItemCfg.itemCfgId or 0
end
def.method("table").SyncItemInfo = function(self, itemInfo)
  if itemInfo == nil then
    return
  end
  self.auctionItemId = itemInfo.itemCfgId
  self.bidderCount = itemInfo.bidderCount
  self.maxBidPrice = itemInfo.maxBidPrice
  self.bidderRoleName = itemInfo.bidderName and _G.GetStringFromOcts(itemInfo.bidderName) or ""
  self.bidderRoleId = itemInfo.bidderRoleId
  self.bidEndTimeStamp = itemInfo.bidEndTimeStamp and Int64.ToNumber(itemInfo.bidEndTimeStamp) or 0
end
def.method("=>", "boolean").IsBidded = function(self)
  return self.bidderRoleId and Int64.gt(self.bidderRoleId, 0)
end
return AuctionItemInfo.Commit()
