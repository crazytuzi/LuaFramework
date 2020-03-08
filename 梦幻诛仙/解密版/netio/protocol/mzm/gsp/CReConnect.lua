local CReConnect = class("CReConnect")
CReConnect.TYPEID = 12590099
function CReConnect:ctor(roleid)
  self.id = 12590099
  self.roleid = roleid or nil
end
function CReConnect:marshal(os)
  os:marshalInt64(self.roleid)
end
function CReConnect:unmarshal(os)
  self.roleid = os:unmarshalInt64()
end
function CReConnect:sizepolicy(size)
  return size <= 65535
end
return CReConnect
