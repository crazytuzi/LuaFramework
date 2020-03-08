local CGetLostExpReq = class("CGetLostExpReq")
CGetLostExpReq.TYPEID = 12583451
function CGetLostExpReq:ctor(activityId)
  self.id = 12583451
  self.activityId = activityId or nil
end
function CGetLostExpReq:marshal(os)
  os:marshalInt32(self.activityId)
end
function CGetLostExpReq:unmarshal(os)
  self.activityId = os:unmarshalInt32()
end
function CGetLostExpReq:sizepolicy(size)
  return size <= 65535
end
return CGetLostExpReq
