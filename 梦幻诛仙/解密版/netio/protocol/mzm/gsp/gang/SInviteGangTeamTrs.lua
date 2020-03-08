local SInviteGangTeamTrs = class("SInviteGangTeamTrs")
SInviteGangTeamTrs.TYPEID = 12589995
function SInviteGangTeamTrs:ctor(inviter_id, gang_teamid)
  self.id = 12589995
  self.inviter_id = inviter_id or nil
  self.gang_teamid = gang_teamid or nil
end
function SInviteGangTeamTrs:marshal(os)
  os:marshalInt64(self.inviter_id)
  os:marshalInt64(self.gang_teamid)
end
function SInviteGangTeamTrs:unmarshal(os)
  self.inviter_id = os:unmarshalInt64()
  self.gang_teamid = os:unmarshalInt64()
end
function SInviteGangTeamTrs:sizepolicy(size)
  return size <= 65535
end
return SInviteGangTeamTrs
