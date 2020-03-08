local SFlowerParadeRoleLeaveFollow = class("SFlowerParadeRoleLeaveFollow")
SFlowerParadeRoleLeaveFollow.TYPEID = 12625670
function SFlowerParadeRoleLeaveFollow:ctor(activityId)
  self.id = 12625670
  self.activityId = activityId or nil
end
function SFlowerParadeRoleLeaveFollow:marshal(os)
  os:marshalInt32(self.activityId)
end
function SFlowerParadeRoleLeaveFollow:unmarshal(os)
  self.activityId = os:unmarshalInt32()
end
function SFlowerParadeRoleLeaveFollow:sizepolicy(size)
  return size <= 65535
end
return SFlowerParadeRoleLeaveFollow
