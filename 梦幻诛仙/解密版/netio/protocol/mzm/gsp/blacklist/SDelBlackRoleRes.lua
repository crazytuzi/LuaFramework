local SDelBlackRoleRes = class("SDelBlackRoleRes")
SDelBlackRoleRes.TYPEID = 12588547
function SDelBlackRoleRes:ctor(del_roleid)
  self.id = 12588547
  self.del_roleid = del_roleid or nil
end
function SDelBlackRoleRes:marshal(os)
  os:marshalInt64(self.del_roleid)
end
function SDelBlackRoleRes:unmarshal(os)
  self.del_roleid = os:unmarshalInt64()
end
function SDelBlackRoleRes:sizepolicy(size)
  return size <= 65535
end
return SDelBlackRoleRes
