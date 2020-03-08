local SRoleDirectionChange = class("SRoleDirectionChange")
SRoleDirectionChange.TYPEID = 12590866
function SRoleDirectionChange:ctor(roleid, direction)
  self.id = 12590866
  self.roleid = roleid or nil
  self.direction = direction or nil
end
function SRoleDirectionChange:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalInt32(self.direction)
end
function SRoleDirectionChange:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.direction = os:unmarshalInt32()
end
function SRoleDirectionChange:sizepolicy(size)
  return size <= 65535
end
return SRoleDirectionChange
