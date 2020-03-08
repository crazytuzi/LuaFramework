local CLeaderRemendMemberReq = class("CLeaderRemendMemberReq")
CLeaderRemendMemberReq.TYPEID = 12607276
function CLeaderRemendMemberReq:ctor(roleid)
  self.id = 12607276
  self.roleid = roleid or nil
end
function CLeaderRemendMemberReq:marshal(os)
  os:marshalInt64(self.roleid)
end
function CLeaderRemendMemberReq:unmarshal(os)
  self.roleid = os:unmarshalInt64()
end
function CLeaderRemendMemberReq:sizepolicy(size)
  return size <= 65535
end
return CLeaderRemendMemberReq
