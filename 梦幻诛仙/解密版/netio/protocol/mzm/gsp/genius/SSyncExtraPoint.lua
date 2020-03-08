local SSyncExtraPoint = class("SSyncExtraPoint")
SSyncExtraPoint.TYPEID = 12613900
function SSyncExtraPoint:ctor(extra_point)
  self.id = 12613900
  self.extra_point = extra_point or nil
end
function SSyncExtraPoint:marshal(os)
  os:marshalInt32(self.extra_point)
end
function SSyncExtraPoint:unmarshal(os)
  self.extra_point = os:unmarshalInt32()
end
function SSyncExtraPoint:sizepolicy(size)
  return size <= 65535
end
return SSyncExtraPoint
