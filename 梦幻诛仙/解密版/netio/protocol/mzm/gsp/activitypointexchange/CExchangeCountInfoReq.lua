local CExchangeCountInfoReq = class("CExchangeCountInfoReq")
CExchangeCountInfoReq.TYPEID = 12624901
function CExchangeCountInfoReq:ctor(activityId)
  self.id = 12624901
  self.activityId = activityId or nil
end
function CExchangeCountInfoReq:marshal(os)
  os:marshalInt32(self.activityId)
end
function CExchangeCountInfoReq:unmarshal(os)
  self.activityId = os:unmarshalInt32()
end
function CExchangeCountInfoReq:sizepolicy(size)
  return size <= 65535
end
return CExchangeCountInfoReq
