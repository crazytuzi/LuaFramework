local ItemInfo = require("netio.protocol.mzm.gsp.auction.ItemInfo")
local SBidError = class("SBidError")
SBidError.TYPEID = 12627207
SBidError.MONEY_NOT_ENOUGH = 1
SBidError.SERVER_LEVEL_LOW = 2
SBidError.ACTIVITY_CLOSE = 3
SBidError.TURN_CLOSE = 4
SBidError.ITEM_NOT_EXIST = 5
SBidError.ITEM_BID_CLOSE = 6
SBidError.MONEY_BELOW_MIN_PRICE = 7
function SBidError:ctor(errorCode, activityId, turnIndex, moneyCount, itemInfo)
  self.id = 12627207
  self.errorCode = errorCode or nil
  self.activityId = activityId or nil
  self.turnIndex = turnIndex or nil
  self.moneyCount = moneyCount or nil
  self.itemInfo = itemInfo or ItemInfo.new()
end
function SBidError:marshal(os)
  os:marshalInt32(self.errorCode)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.turnIndex)
  os:marshalInt64(self.moneyCount)
  self.itemInfo:marshal(os)
end
function SBidError:unmarshal(os)
  self.errorCode = os:unmarshalInt32()
  self.activityId = os:unmarshalInt32()
  self.turnIndex = os:unmarshalInt32()
  self.moneyCount = os:unmarshalInt64()
  self.itemInfo = ItemInfo.new()
  self.itemInfo:unmarshal(os)
end
function SBidError:sizepolicy(size)
  return size <= 65535
end
return SBidError
