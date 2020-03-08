local SSyncChangeDuty = class("SSyncChangeDuty")
SSyncChangeDuty.TYPEID = 12589832
function SSyncChangeDuty:ctor(targetId, duty, managerId)
  self.id = 12589832
  self.targetId = targetId or nil
  self.duty = duty or nil
  self.managerId = managerId or nil
end
function SSyncChangeDuty:marshal(os)
  os:marshalInt64(self.targetId)
  os:marshalInt32(self.duty)
  os:marshalInt64(self.managerId)
end
function SSyncChangeDuty:unmarshal(os)
  self.targetId = os:unmarshalInt64()
  self.duty = os:unmarshalInt32()
  self.managerId = os:unmarshalInt64()
end
function SSyncChangeDuty:sizepolicy(size)
  return size <= 65535
end
return SSyncChangeDuty
