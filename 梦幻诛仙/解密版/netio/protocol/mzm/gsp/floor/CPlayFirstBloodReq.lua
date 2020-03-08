local CPlayFirstBloodReq = class("CPlayFirstBloodReq")
CPlayFirstBloodReq.TYPEID = 12617741
function CPlayFirstBloodReq:ctor(activityId, floor)
  self.id = 12617741
  self.activityId = activityId or nil
  self.floor = floor or nil
end
function CPlayFirstBloodReq:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.floor)
end
function CPlayFirstBloodReq:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.floor = os:unmarshalInt32()
end
function CPlayFirstBloodReq:sizepolicy(size)
  return size <= 65535
end
return CPlayFirstBloodReq
