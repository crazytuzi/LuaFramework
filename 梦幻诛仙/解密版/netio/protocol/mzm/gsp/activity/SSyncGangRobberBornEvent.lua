local SSyncGangRobberBornEvent = class("SSyncGangRobberBornEvent")
SSyncGangRobberBornEvent.TYPEID = 12587562
function SSyncGangRobberBornEvent:ctor(robberNo)
  self.id = 12587562
  self.robberNo = robberNo or nil
end
function SSyncGangRobberBornEvent:marshal(os)
  os:marshalInt32(self.robberNo)
end
function SSyncGangRobberBornEvent:unmarshal(os)
  self.robberNo = os:unmarshalInt32()
end
function SSyncGangRobberBornEvent:sizepolicy(size)
  return size <= 65535
end
return SSyncGangRobberBornEvent
