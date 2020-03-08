local SSyncMiFangCountChange = class("SSyncMiFangCountChange")
SSyncMiFangCountChange.TYPEID = 12589928
function SSyncMiFangCountChange:ctor(count)
  self.id = 12589928
  self.count = count or nil
end
function SSyncMiFangCountChange:marshal(os)
  os:marshalInt32(self.count)
end
function SSyncMiFangCountChange:unmarshal(os)
  self.count = os:unmarshalInt32()
end
function SSyncMiFangCountChange:sizepolicy(size)
  return size <= 65535
end
return SSyncMiFangCountChange
