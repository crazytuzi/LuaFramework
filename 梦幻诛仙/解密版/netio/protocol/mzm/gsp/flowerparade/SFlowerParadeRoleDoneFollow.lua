local SFlowerParadeRoleDoneFollow = class("SFlowerParadeRoleDoneFollow")
SFlowerParadeRoleDoneFollow.TYPEID = 12625677
function SFlowerParadeRoleDoneFollow:ctor(activityId, doneTime)
  self.id = 12625677
  self.activityId = activityId or nil
  self.doneTime = doneTime or nil
end
function SFlowerParadeRoleDoneFollow:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.doneTime)
end
function SFlowerParadeRoleDoneFollow:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.doneTime = os:unmarshalInt32()
end
function SFlowerParadeRoleDoneFollow:sizepolicy(size)
  return size <= 65535
end
return SFlowerParadeRoleDoneFollow
