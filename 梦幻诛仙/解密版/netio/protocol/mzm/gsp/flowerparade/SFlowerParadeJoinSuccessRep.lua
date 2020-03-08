local SFlowerParadeJoinSuccessRep = class("SFlowerParadeJoinSuccessRep")
SFlowerParadeJoinSuccessRep.TYPEID = 12625665
function SFlowerParadeJoinSuccessRep:ctor(activityId)
  self.id = 12625665
  self.activityId = activityId or nil
end
function SFlowerParadeJoinSuccessRep:marshal(os)
  os:marshalInt32(self.activityId)
end
function SFlowerParadeJoinSuccessRep:unmarshal(os)
  self.activityId = os:unmarshalInt32()
end
function SFlowerParadeJoinSuccessRep:sizepolicy(size)
  return size <= 65535
end
return SFlowerParadeJoinSuccessRep
