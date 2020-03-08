local CCheckFirstBloodReq = class("CCheckFirstBloodReq")
CCheckFirstBloodReq.TYPEID = 12617745
function CCheckFirstBloodReq:ctor(activityId, floor)
  self.id = 12617745
  self.activityId = activityId or nil
  self.floor = floor or nil
end
function CCheckFirstBloodReq:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.floor)
end
function CCheckFirstBloodReq:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.floor = os:unmarshalInt32()
end
function CCheckFirstBloodReq:sizepolicy(size)
  return size <= 65535
end
return CCheckFirstBloodReq
