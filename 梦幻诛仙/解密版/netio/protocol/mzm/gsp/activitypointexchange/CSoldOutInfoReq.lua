local CSoldOutInfoReq = class("CSoldOutInfoReq")
CSoldOutInfoReq.TYPEID = 12624903
function CSoldOutInfoReq:ctor(activityId)
  self.id = 12624903
  self.activityId = activityId or nil
end
function CSoldOutInfoReq:marshal(os)
  os:marshalInt32(self.activityId)
end
function CSoldOutInfoReq:unmarshal(os)
  self.activityId = os:unmarshalInt32()
end
function CSoldOutInfoReq:sizepolicy(size)
  return size <= 65535
end
return CSoldOutInfoReq
