local CGetBidRankReq = class("CGetBidRankReq")
CGetBidRankReq.TYPEID = 12627201
function CGetBidRankReq:ctor(activityId)
  self.id = 12627201
  self.activityId = activityId or nil
end
function CGetBidRankReq:marshal(os)
  os:marshalInt32(self.activityId)
end
function CGetBidRankReq:unmarshal(os)
  self.activityId = os:unmarshalInt32()
end
function CGetBidRankReq:sizepolicy(size)
  return size <= 65535
end
return CGetBidRankReq
