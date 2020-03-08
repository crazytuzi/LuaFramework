local CLoginRole = class("CLoginRole")
CLoginRole.TYPEID = 12590085
function CLoginRole:ctor(roleid)
  self.id = 12590085
  self.roleid = roleid or nil
end
function CLoginRole:marshal(os)
  os:marshalInt64(self.roleid)
end
function CLoginRole:unmarshal(os)
  self.roleid = os:unmarshalInt64()
end
function CLoginRole:sizepolicy(size)
  return size <= 256
end
return CLoginRole
