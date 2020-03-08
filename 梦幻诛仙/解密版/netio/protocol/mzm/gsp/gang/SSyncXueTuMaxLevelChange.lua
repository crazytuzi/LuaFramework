local SSyncXueTuMaxLevelChange = class("SSyncXueTuMaxLevelChange")
SSyncXueTuMaxLevelChange.TYPEID = 12589834
function SSyncXueTuMaxLevelChange:ctor(level)
  self.id = 12589834
  self.level = level or nil
end
function SSyncXueTuMaxLevelChange:marshal(os)
  os:marshalInt32(self.level)
end
function SSyncXueTuMaxLevelChange:unmarshal(os)
  self.level = os:unmarshalInt32()
end
function SSyncXueTuMaxLevelChange:sizepolicy(size)
  return size <= 65535
end
return SSyncXueTuMaxLevelChange
