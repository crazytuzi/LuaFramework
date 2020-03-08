local SFlowerParadeRoleJoinFollow = class("SFlowerParadeRoleJoinFollow")
SFlowerParadeRoleJoinFollow.TYPEID = 12625668
function SFlowerParadeRoleJoinFollow:ctor(activityId)
  self.id = 12625668
  self.activityId = activityId or nil
end
function SFlowerParadeRoleJoinFollow:marshal(os)
  os:marshalInt32(self.activityId)
end
function SFlowerParadeRoleJoinFollow:unmarshal(os)
  self.activityId = os:unmarshalInt32()
end
function SFlowerParadeRoleJoinFollow:sizepolicy(size)
  return size <= 65535
end
return SFlowerParadeRoleJoinFollow
