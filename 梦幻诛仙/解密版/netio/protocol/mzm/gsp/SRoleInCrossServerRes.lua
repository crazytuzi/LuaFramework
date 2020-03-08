local SRoleInCrossServerRes = class("SRoleInCrossServerRes")
SRoleInCrossServerRes.TYPEID = 12590103
function SRoleInCrossServerRes:ctor(roleid, zoneid, token)
  self.id = 12590103
  self.roleid = roleid or nil
  self.zoneid = zoneid or nil
  self.token = token or nil
end
function SRoleInCrossServerRes:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalInt32(self.zoneid)
  os:marshalOctets(self.token)
end
function SRoleInCrossServerRes:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.zoneid = os:unmarshalInt32()
  self.token = os:unmarshalOctets()
end
function SRoleInCrossServerRes:sizepolicy(size)
  return size <= 10240
end
return SRoleInCrossServerRes
