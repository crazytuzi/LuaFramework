local SSyncMiFangLevelNotEqual = class("SSyncMiFangLevelNotEqual")
SSyncMiFangLevelNotEqual.TYPEID = 12589929
function SSyncMiFangLevelNotEqual:ctor(level)
  self.id = 12589929
  self.level = level or nil
end
function SSyncMiFangLevelNotEqual:marshal(os)
  os:marshalInt32(self.level)
end
function SSyncMiFangLevelNotEqual:unmarshal(os)
  self.level = os:unmarshalInt32()
end
function SSyncMiFangLevelNotEqual:sizepolicy(size)
  return size <= 65535
end
return SSyncMiFangLevelNotEqual
