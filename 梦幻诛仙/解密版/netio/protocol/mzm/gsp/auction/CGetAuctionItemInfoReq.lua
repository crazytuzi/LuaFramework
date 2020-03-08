local CGetAuctionItemInfoReq = class("CGetAuctionItemInfoReq")
CGetAuctionItemInfoReq.TYPEID = 12627202
function CGetAuctionItemInfoReq:ctor(activityId, turnIndex, itemCfgId)
  self.id = 12627202
  self.activityId = activityId or nil
  self.turnIndex = turnIndex or nil
  self.itemCfgId = itemCfgId or nil
end
function CGetAuctionItemInfoReq:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.turnIndex)
  os:marshalInt32(self.itemCfgId)
end
function CGetAuctionItemInfoReq:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.turnIndex = os:unmarshalInt32()
  self.itemCfgId = os:unmarshalInt32()
end
function CGetAuctionItemInfoReq:sizepolicy(size)
  return size <= 65535
end
return CGetAuctionItemInfoReq
