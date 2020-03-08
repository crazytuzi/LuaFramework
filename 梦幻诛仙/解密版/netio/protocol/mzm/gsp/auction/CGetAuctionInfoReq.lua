local CGetAuctionInfoReq = class("CGetAuctionInfoReq")
CGetAuctionInfoReq.TYPEID = 12627204
function CGetAuctionInfoReq:ctor(activityId, turnIndex)
  self.id = 12627204
  self.activityId = activityId or nil
  self.turnIndex = turnIndex or nil
end
function CGetAuctionInfoReq:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.turnIndex)
end
function CGetAuctionInfoReq:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.turnIndex = os:unmarshalInt32()
end
function CGetAuctionInfoReq:sizepolicy(size)
  return size <= 65535
end
return CGetAuctionInfoReq
