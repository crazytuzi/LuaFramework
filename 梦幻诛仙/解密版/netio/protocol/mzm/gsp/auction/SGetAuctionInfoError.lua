local SGetAuctionInfoError = class("SGetAuctionInfoError")
SGetAuctionInfoError.TYPEID = 12627212
SGetAuctionInfoError.SERVER_LEVEL_LOW = 1
SGetAuctionInfoError.ACTIVITY_CLOSE = 2
SGetAuctionInfoError.NO_ITEM = 3
function SGetAuctionInfoError:ctor(activityId, turnIndex, errorCode)
  self.id = 12627212
  self.activityId = activityId or nil
  self.turnIndex = turnIndex or nil
  self.errorCode = errorCode or nil
end
function SGetAuctionInfoError:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.turnIndex)
  os:marshalInt32(self.errorCode)
end
function SGetAuctionInfoError:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.turnIndex = os:unmarshalInt32()
  self.errorCode = os:unmarshalInt32()
end
function SGetAuctionInfoError:sizepolicy(size)
  return size <= 65535
end
return SGetAuctionInfoError
