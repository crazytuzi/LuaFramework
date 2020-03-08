local SRoleExtraRemoveBrd = class("SRoleExtraRemoveBrd")
SRoleExtraRemoveBrd.TYPEID = 12590903
function SRoleExtraRemoveBrd:ctor(roleid, extra_type)
  self.id = 12590903
  self.roleid = roleid or nil
  self.extra_type = extra_type or nil
end
function SRoleExtraRemoveBrd:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalInt32(self.extra_type)
end
function SRoleExtraRemoveBrd:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.extra_type = os:unmarshalInt32()
end
function SRoleExtraRemoveBrd:sizepolicy(size)
  return size <= 65535
end
return SRoleExtraRemoveBrd
