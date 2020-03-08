local SRoleExtraUpdateBrd = class("SRoleExtraUpdateBrd")
SRoleExtraUpdateBrd.TYPEID = 12590904
function SRoleExtraUpdateBrd:ctor(roleid, extra_type, extra_content)
  self.id = 12590904
  self.roleid = roleid or nil
  self.extra_type = extra_type or nil
  self.extra_content = extra_content or nil
end
function SRoleExtraUpdateBrd:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalInt32(self.extra_type)
  os:marshalOctets(self.extra_content)
end
function SRoleExtraUpdateBrd:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.extra_type = os:unmarshalInt32()
  self.extra_content = os:unmarshalOctets()
end
function SRoleExtraUpdateBrd:sizepolicy(size)
  return size <= 65535
end
return SRoleExtraUpdateBrd
