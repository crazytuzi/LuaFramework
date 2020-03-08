local SFlowerParadeDoDance = class("SFlowerParadeDoDance")
SFlowerParadeDoDance.TYPEID = 12625675
function SFlowerParadeDoDance:ctor(actionIndex, activityId)
  self.id = 12625675
  self.actionIndex = actionIndex or nil
  self.activityId = activityId or nil
end
function SFlowerParadeDoDance:marshal(os)
  os:marshalInt32(self.actionIndex)
  os:marshalInt32(self.activityId)
end
function SFlowerParadeDoDance:unmarshal(os)
  self.actionIndex = os:unmarshalInt32()
  self.activityId = os:unmarshalInt32()
end
function SFlowerParadeDoDance:sizepolicy(size)
  return size <= 65535
end
return SFlowerParadeDoDance
