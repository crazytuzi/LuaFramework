local SRefuseJoinCorps = class("SRefuseJoinCorps")
SRefuseJoinCorps.TYPEID = 12617477
function SRefuseJoinCorps:ctor(roleId, roleName)
  self.id = 12617477
  self.roleId = roleId or nil
  self.roleName = roleName or nil
end
function SRefuseJoinCorps:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalOctets(self.roleName)
end
function SRefuseJoinCorps:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.roleName = os:unmarshalOctets()
end
function SRefuseJoinCorps:sizepolicy(size)
  return size <= 65535
end
return SRefuseJoinCorps
