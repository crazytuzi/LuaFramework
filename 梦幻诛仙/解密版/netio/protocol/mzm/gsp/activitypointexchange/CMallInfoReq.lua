local CMallInfoReq = class("CMallInfoReq")
CMallInfoReq.TYPEID = 12624909
function CMallInfoReq:ctor(activityId)
  self.id = 12624909
  self.activityId = activityId or nil
end
function CMallInfoReq:marshal(os)
  os:marshalInt32(self.activityId)
end
function CMallInfoReq:unmarshal(os)
  self.activityId = os:unmarshalInt32()
end
function CMallInfoReq:sizepolicy(size)
  return size <= 65535
end
return CMallInfoReq
