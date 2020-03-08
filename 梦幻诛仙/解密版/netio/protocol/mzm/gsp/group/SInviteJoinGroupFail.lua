local SInviteJoinGroupFail = class("SInviteJoinGroupFail")
SInviteJoinGroupFail.TYPEID = 12605215
SInviteJoinGroupFail.GROUP_NOT_EXIST = 1
SInviteJoinGroupFail.INVITER_NOT_IN_GROUP = 2
SInviteJoinGroupFail.GROUP_MEMBER_FULL = 3
SInviteJoinGroupFail.INVITEE_LEVEL_NOT_ENOUGH = 4
SInviteJoinGroupFail.INVITEE_IN_GROUP = 5
SInviteJoinGroupFail.INVITEE_JOIN_GROUP_TO_LIMIT = 6
SInviteJoinGroupFail.INVITER_AND_INVITEE_ARENOT_FRIENDS = 7
function SInviteJoinGroupFail:ctor(res)
  self.id = 12605215
  self.res = res or nil
end
function SInviteJoinGroupFail:marshal(os)
  os:marshalInt32(self.res)
end
function SInviteJoinGroupFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SInviteJoinGroupFail:sizepolicy(size)
  return size <= 65535
end
return SInviteJoinGroupFail
