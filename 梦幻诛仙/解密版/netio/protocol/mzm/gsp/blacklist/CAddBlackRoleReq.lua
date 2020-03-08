local CAddBlackRoleReq = class("CAddBlackRoleReq")
CAddBlackRoleReq.TYPEID = 12588551
function CAddBlackRoleReq:ctor(black_roleid)
  self.id = 12588551
  self.black_roleid = black_roleid or nil
end
function CAddBlackRoleReq:marshal(os)
  os:marshalInt64(self.black_roleid)
end
function CAddBlackRoleReq:unmarshal(os)
  self.black_roleid = os:unmarshalInt64()
end
function CAddBlackRoleReq:sizepolicy(size)
  return size <= 65535
end
return CAddBlackRoleReq
