local SSyncGangRobberCounter = class("SSyncGangRobberCounter")
SSyncGangRobberCounter.TYPEID = 12587523
function SSyncGangRobberCounter:ctor(count)
  self.id = 12587523
  self.count = count or nil
end
function SSyncGangRobberCounter:marshal(os)
  os:marshalInt32(self.count)
end
function SSyncGangRobberCounter:unmarshal(os)
  self.count = os:unmarshalInt32()
end
function SSyncGangRobberCounter:sizepolicy(size)
  return size <= 65535
end
return SSyncGangRobberCounter
