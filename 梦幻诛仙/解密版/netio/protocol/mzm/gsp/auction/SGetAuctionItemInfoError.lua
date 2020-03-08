local SGetAuctionItemInfoError = class("SGetAuctionItemInfoError")
SGetAuctionItemInfoError.TYPEID = 12627210
SGetAuctionItemInfoError.SERVER_LEVEL_LOW = 1
SGetAuctionItemInfoError.ACTIVITY_CLOSE = 2
SGetAuctionItemInfoError.ITEM_NOT_EXIST = 3
function SGetAuctionItemInfoError:ctor(activityId, turnIndex, itemCfgId, errorCode)
  self.id = 12627210
  self.activityId = activityId or nil
  self.turnIndex = turnIndex or nil
  self.itemCfgId = itemCfgId or nil
  self.errorCode = errorCode or nil
end
function SGetAuctionItemInfoError:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.turnIndex)
  os:marshalInt32(self.itemCfgId)
  os:marshalInt32(self.errorCode)
end
function SGetAuctionItemInfoError:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.turnIndex = os:unmarshalInt32()
  self.itemCfgId = os:unmarshalInt32()
  self.errorCode = os:unmarshalInt32()
end
function SGetAuctionItemInfoError:sizepolicy(size)
  return size <= 65535
end
return SGetAuctionItemInfoError
