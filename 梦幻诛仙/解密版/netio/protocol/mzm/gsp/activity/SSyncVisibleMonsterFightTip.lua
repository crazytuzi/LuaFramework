local SSyncVisibleMonsterFightTip = class("SSyncVisibleMonsterFightTip")
SSyncVisibleMonsterFightTip.TYPEID = 12587531
function SSyncVisibleMonsterFightTip:ctor(activityId)
  self.id = 12587531
  self.activityId = activityId or nil
end
function SSyncVisibleMonsterFightTip:marshal(os)
  os:marshalInt32(self.activityId)
end
function SSyncVisibleMonsterFightTip:unmarshal(os)
  self.activityId = os:unmarshalInt32()
end
function SSyncVisibleMonsterFightTip:sizepolicy(size)
  return size <= 65535
end
return SSyncVisibleMonsterFightTip
