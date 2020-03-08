local SInviteJoinGang = class("SInviteJoinGang")
SInviteJoinGang.TYPEID = 12589858
function SInviteJoinGang:ctor(inviterId, inviterName, gangId, gangName)
  self.id = 12589858
  self.inviterId = inviterId or nil
  self.inviterName = inviterName or nil
  self.gangId = gangId or nil
  self.gangName = gangName or nil
end
function SInviteJoinGang:marshal(os)
  os:marshalInt64(self.inviterId)
  os:marshalString(self.inviterName)
  os:marshalInt64(self.gangId)
  os:marshalString(self.gangName)
end
function SInviteJoinGang:unmarshal(os)
  self.inviterId = os:unmarshalInt64()
  self.inviterName = os:unmarshalString()
  self.gangId = os:unmarshalInt64()
  self.gangName = os:unmarshalString()
end
function SInviteJoinGang:sizepolicy(size)
  return size <= 65535
end
return SInviteJoinGang
