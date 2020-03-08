local SSynFunctionOpenSchedule = class("SSynFunctionOpenSchedule")
SSynFunctionOpenSchedule.TYPEID = 12596999
function SSynFunctionOpenSchedule:ctor(targetId, targetState)
  self.id = 12596999
  self.targetId = targetId or nil
  self.targetState = targetState or nil
end
function SSynFunctionOpenSchedule:marshal(os)
  os:marshalInt32(self.targetId)
  os:marshalInt32(self.targetState)
end
function SSynFunctionOpenSchedule:unmarshal(os)
  self.targetId = os:unmarshalInt32()
  self.targetState = os:unmarshalInt32()
end
function SSynFunctionOpenSchedule:sizepolicy(size)
  return size <= 65535
end
return SSynFunctionOpenSchedule
