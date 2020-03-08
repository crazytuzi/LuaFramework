local SGetChangeNameVoteInfoRes = class("SGetChangeNameVoteInfoRes")
SGetChangeNameVoteInfoRes.TYPEID = 12597813
function SGetChangeNameVoteInfoRes:ctor(name1, name2, rolename, verifytime, curvotecount, needvotecount)
  self.id = 12597813
  self.name1 = name1 or nil
  self.name2 = name2 or nil
  self.rolename = rolename or nil
  self.verifytime = verifytime or nil
  self.curvotecount = curvotecount or nil
  self.needvotecount = needvotecount or nil
end
function SGetChangeNameVoteInfoRes:marshal(os)
  os:marshalString(self.name1)
  os:marshalString(self.name2)
  os:marshalString(self.rolename)
  os:marshalInt64(self.verifytime)
  os:marshalInt32(self.curvotecount)
  os:marshalInt32(self.needvotecount)
end
function SGetChangeNameVoteInfoRes:unmarshal(os)
  self.name1 = os:unmarshalString()
  self.name2 = os:unmarshalString()
  self.rolename = os:unmarshalString()
  self.verifytime = os:unmarshalInt64()
  self.curvotecount = os:unmarshalInt32()
  self.needvotecount = os:unmarshalInt32()
end
function SGetChangeNameVoteInfoRes:sizepolicy(size)
  return size <= 65535
end
return SGetChangeNameVoteInfoRes
