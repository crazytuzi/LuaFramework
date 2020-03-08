local SGetRoleNameRep = class("SGetRoleNameRep")
SGetRoleNameRep.TYPEID = 12586037
function SGetRoleNameRep:ctor(checkedRoleId, checkedRoleName)
  self.id = 12586037
  self.checkedRoleId = checkedRoleId or nil
  self.checkedRoleName = checkedRoleName or nil
end
function SGetRoleNameRep:marshal(os)
  os:marshalInt64(self.checkedRoleId)
  os:marshalOctets(self.checkedRoleName)
end
function SGetRoleNameRep:unmarshal(os)
  self.checkedRoleId = os:unmarshalInt64()
  self.checkedRoleName = os:unmarshalOctets()
end
function SGetRoleNameRep:sizepolicy(size)
  return size <= 65535
end
return SGetRoleNameRep
