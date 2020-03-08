local ItemInfo = require("netio.protocol.mzm.gsp.auction.ItemInfo")
local SSynAuctionItemInfo = class("SSynAuctionItemInfo")
SSynAuctionItemInfo.TYPEID = 12627205
function SSynAuctionItemInfo:ctor(activityId, turnIndex, itemInfo)
  self.id = 12627205
  self.activityId = activityId or nil
  self.turnIndex = turnIndex or nil
  self.itemInfo = itemInfo or ItemInfo.new()
end
function SSynAuctionItemInfo:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.turnIndex)
  self.itemInfo:marshal(os)
end
function SSynAuctionItemInfo:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.turnIndex = os:unmarshalInt32()
  self.itemInfo = ItemInfo.new()
  self.itemInfo:unmarshal(os)
end
function SSynAuctionItemInfo:sizepolicy(size)
  return size <= 65535
end
return SSynAuctionItemInfo
