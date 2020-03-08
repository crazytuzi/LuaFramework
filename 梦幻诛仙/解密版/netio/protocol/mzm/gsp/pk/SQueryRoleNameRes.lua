local SQueryRoleNameRes = class("SQueryRoleNameRes")
SQueryRoleNameRes.TYPEID = 12619803
function SQueryRoleNameRes:ctor(role_name)
  self.id = 12619803
  self.role_name = role_name or nil
end
function SQueryRoleNameRes:marshal(os)
  os:marshalOctets(self.role_name)
end
function SQueryRoleNameRes:unmarshal(os)
  self.role_name = os:unmarshalOctets()
end
function SQueryRoleNameRes:sizepolicy(size)
  return size <= 65535
end
return SQueryRoleNameRes
