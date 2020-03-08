local SGetKickoutVoteInfoRes = class("SGetKickoutVoteInfoRes")
SGetKickoutVoteInfoRes.TYPEID = 12597814
function SGetKickoutVoteInfoRes:ctor(rolename, kickrolename, kickrolegender, kickrolemenpai, kickroletitle, verifytime, agreecount, notagreecount, needvotecount)
  self.id = 12597814
  self.rolename = rolename or nil
  self.kickrolename = kickrolename or nil
  self.kickrolegender = kickrolegender or nil
  self.kickrolemenpai = kickrolemenpai or nil
  self.kickroletitle = kickroletitle or nil
  self.verifytime = verifytime or nil
  self.agreecount = agreecount or nil
  self.notagreecount = notagreecount or nil
  self.needvotecount = needvotecount or nil
end
function SGetKickoutVoteInfoRes:marshal(os)
  os:marshalString(self.rolename)
  os:marshalString(self.kickrolename)
  os:marshalInt32(self.kickrolegender)
  os:marshalInt32(self.kickrolemenpai)
  os:marshalString(self.kickroletitle)
  os:marshalInt64(self.verifytime)
  os:marshalInt32(self.agreecount)
  os:marshalInt32(self.notagreecount)
  os:marshalInt32(self.needvotecount)
end
function SGetKickoutVoteInfoRes:unmarshal(os)
  self.rolename = os:unmarshalString()
  self.kickrolename = os:unmarshalString()
  self.kickrolegender = os:unmarshalInt32()
  self.kickrolemenpai = os:unmarshalInt32()
  self.kickroletitle = os:unmarshalString()
  self.verifytime = os:unmarshalInt64()
  self.agreecount = os:unmarshalInt32()
  self.notagreecount = os:unmarshalInt32()
  self.needvotecount = os:unmarshalInt32()
end
function SGetKickoutVoteInfoRes:sizepolicy(size)
  return size <= 65535
end
return SGetKickoutVoteInfoRes
