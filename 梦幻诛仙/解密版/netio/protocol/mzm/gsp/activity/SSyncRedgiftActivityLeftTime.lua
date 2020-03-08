local SSyncRedgiftActivityLeftTime = class("SSyncRedgiftActivityLeftTime")
SSyncRedgiftActivityLeftTime.TYPEID = 12587594
function SSyncRedgiftActivityLeftTime:ctor(leftTime)
  self.id = 12587594
  self.leftTime = leftTime or nil
end
function SSyncRedgiftActivityLeftTime:marshal(os)
  os:marshalInt32(self.leftTime)
end
function SSyncRedgiftActivityLeftTime:unmarshal(os)
  self.leftTime = os:unmarshalInt32()
end
function SSyncRedgiftActivityLeftTime:sizepolicy(size)
  return size <= 65535
end
return SSyncRedgiftActivityLeftTime
