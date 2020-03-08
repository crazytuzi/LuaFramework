local SFlowerParadeDoSing = class("SFlowerParadeDoSing")
SFlowerParadeDoSing.TYPEID = 12625673
function SFlowerParadeDoSing:ctor(actionIndex, activityId)
  self.id = 12625673
  self.actionIndex = actionIndex or nil
  self.activityId = activityId or nil
end
function SFlowerParadeDoSing:marshal(os)
  os:marshalInt32(self.actionIndex)
  os:marshalInt32(self.activityId)
end
function SFlowerParadeDoSing:unmarshal(os)
  self.actionIndex = os:unmarshalInt32()
  self.activityId = os:unmarshalInt32()
end
function SFlowerParadeDoSing:sizepolicy(size)
  return size <= 65535
end
return SFlowerParadeDoSing
