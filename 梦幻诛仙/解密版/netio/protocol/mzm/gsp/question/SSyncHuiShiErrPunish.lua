local SSyncHuiShiErrPunish = class("SSyncHuiShiErrPunish")
SSyncHuiShiErrPunish.TYPEID = 12594708
function SSyncHuiShiErrPunish:ctor(totalAddTime)
  self.id = 12594708
  self.totalAddTime = totalAddTime or nil
end
function SSyncHuiShiErrPunish:marshal(os)
  os:marshalInt32(self.totalAddTime)
end
function SSyncHuiShiErrPunish:unmarshal(os)
  self.totalAddTime = os:unmarshalInt32()
end
function SSyncHuiShiErrPunish:sizepolicy(size)
  return size <= 65535
end
return SSyncHuiShiErrPunish
