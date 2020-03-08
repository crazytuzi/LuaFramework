local CDelBlackRoleReq = class("CDelBlackRoleReq")
CDelBlackRoleReq.TYPEID = 12588546
function CDelBlackRoleReq:ctor(black_roleid)
  self.id = 12588546
  self.black_roleid = black_roleid or nil
end
function CDelBlackRoleReq:marshal(os)
  os:marshalInt64(self.black_roleid)
end
function CDelBlackRoleReq:unmarshal(os)
  self.black_roleid = os:unmarshalInt64()
end
function CDelBlackRoleReq:sizepolicy(size)
  return size <= 65535
end
return CDelBlackRoleReq
