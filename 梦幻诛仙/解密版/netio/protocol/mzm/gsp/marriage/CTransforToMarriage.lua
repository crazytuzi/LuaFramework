local CTransforToMarriage = class("CTransforToMarriage")
CTransforToMarriage.TYPEID = 12599819
function CTransforToMarriage:ctor(roleid)
  self.id = 12599819
  self.roleid = roleid or nil
end
function CTransforToMarriage:marshal(os)
  os:marshalInt64(self.roleid)
end
function CTransforToMarriage:unmarshal(os)
  self.roleid = os:unmarshalInt64()
end
function CTransforToMarriage:sizepolicy(size)
  return size <= 65535
end
return CTransforToMarriage
