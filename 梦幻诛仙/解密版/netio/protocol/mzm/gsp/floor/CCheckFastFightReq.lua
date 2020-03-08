local CCheckFastFightReq = class("CCheckFastFightReq")
CCheckFastFightReq.TYPEID = 12617747
function CCheckFastFightReq:ctor(activityId, floor)
  self.id = 12617747
  self.activityId = activityId or nil
  self.floor = floor or nil
end
function CCheckFastFightReq:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.floor)
end
function CCheckFastFightReq:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.floor = os:unmarshalInt32()
end
function CCheckFastFightReq:sizepolicy(size)
  return size <= 65535
end
return CCheckFastFightReq
