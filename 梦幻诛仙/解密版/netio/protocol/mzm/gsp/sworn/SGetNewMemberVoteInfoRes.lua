local SGetNewMemberVoteInfoRes = class("SGetNewMemberVoteInfoRes")
SGetNewMemberVoteInfoRes.TYPEID = 12597810
function SGetNewMemberVoteInfoRes:ctor(roleid, rolename, rolegender, rolemenpai, roletitle, invitename, verifytime, curvotecount, needvotecount)
  self.id = 12597810
  self.roleid = roleid or nil
  self.rolename = rolename or nil
  self.rolegender = rolegender or nil
  self.rolemenpai = rolemenpai or nil
  self.roletitle = roletitle or nil
  self.invitename = invitename or nil
  self.verifytime = verifytime or nil
  self.curvotecount = curvotecount or nil
  self.needvotecount = needvotecount or nil
end
function SGetNewMemberVoteInfoRes:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalString(self.rolename)
  os:marshalInt32(self.rolegender)
  os:marshalInt32(self.rolemenpai)
  os:marshalString(self.roletitle)
  os:marshalString(self.invitename)
  os:marshalInt64(self.verifytime)
  os:marshalInt32(self.curvotecount)
  os:marshalInt32(self.needvotecount)
end
function SGetNewMemberVoteInfoRes:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.rolename = os:unmarshalString()
  self.rolegender = os:unmarshalInt32()
  self.rolemenpai = os:unmarshalInt32()
  self.roletitle = os:unmarshalString()
  self.invitename = os:unmarshalString()
  self.verifytime = os:unmarshalInt64()
  self.curvotecount = os:unmarshalInt32()
  self.needvotecount = os:unmarshalInt32()
end
function SGetNewMemberVoteInfoRes:sizepolicy(size)
  return size <= 65535
end
return SGetNewMemberVoteInfoRes
