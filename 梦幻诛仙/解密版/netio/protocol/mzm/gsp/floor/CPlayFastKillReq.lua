local CPlayFastKillReq = class("CPlayFastKillReq")
CPlayFastKillReq.TYPEID = 12617733
function CPlayFastKillReq:ctor(activityId, floor)
  self.id = 12617733
  self.activityId = activityId or nil
  self.floor = floor or nil
end
function CPlayFastKillReq:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.floor)
end
function CPlayFastKillReq:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.floor = os:unmarshalInt32()
end
function CPlayFastKillReq:sizepolicy(size)
  return size <= 65535
end
return CPlayFastKillReq
