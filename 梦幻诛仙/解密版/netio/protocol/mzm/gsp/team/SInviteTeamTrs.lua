local SInviteTeamTrs = class("SInviteTeamTrs")
SInviteTeamTrs.TYPEID = 12588295
function SInviteTeamTrs:ctor(inviter, name, level, menpai, gender, avatarId, avatarFrameid, sessionid)
  self.id = 12588295
  self.inviter = inviter or nil
  self.name = name or nil
  self.level = level or nil
  self.menpai = menpai or nil
  self.gender = gender or nil
  self.avatarId = avatarId or nil
  self.avatarFrameid = avatarFrameid or nil
  self.sessionid = sessionid or nil
end
function SInviteTeamTrs:marshal(os)
  os:marshalInt64(self.inviter)
  os:marshalString(self.name)
  os:marshalInt32(self.level)
  os:marshalInt32(self.menpai)
  os:marshalInt32(self.gender)
  os:marshalInt32(self.avatarId)
  os:marshalInt32(self.avatarFrameid)
  os:marshalInt64(self.sessionid)
end
function SInviteTeamTrs:unmarshal(os)
  self.inviter = os:unmarshalInt64()
  self.name = os:unmarshalString()
  self.level = os:unmarshalInt32()
  self.menpai = os:unmarshalInt32()
  self.gender = os:unmarshalInt32()
  self.avatarId = os:unmarshalInt32()
  self.avatarFrameid = os:unmarshalInt32()
  self.sessionid = os:unmarshalInt64()
end
function SInviteTeamTrs:sizepolicy(size)
  return size <= 65535
end
return SInviteTeamTrs
