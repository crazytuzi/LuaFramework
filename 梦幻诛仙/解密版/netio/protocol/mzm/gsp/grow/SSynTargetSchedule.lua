local SSynTargetSchedule = class("SSynTargetSchedule")
SSynTargetSchedule.TYPEID = 12596993
function SSynTargetSchedule:ctor(targetId, targetState, targetParam)
  self.id = 12596993
  self.targetId = targetId or nil
  self.targetState = targetState or nil
  self.targetParam = targetParam or nil
end
function SSynTargetSchedule:marshal(os)
  os:marshalInt32(self.targetId)
  os:marshalInt32(self.targetState)
  os:marshalInt32(self.targetParam)
end
function SSynTargetSchedule:unmarshal(os)
  self.targetId = os:unmarshalInt32()
  self.targetState = os:unmarshalInt32()
  self.targetParam = os:unmarshalInt32()
end
function SSynTargetSchedule:sizepolicy(size)
  return size <= 65535
end
return SSynTargetSchedule
