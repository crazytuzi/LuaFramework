local CRoleDirectionChange = class("CRoleDirectionChange")
CRoleDirectionChange.TYPEID = 12590849
function CRoleDirectionChange:ctor(direction)
  self.id = 12590849
  self.direction = direction or nil
end
function CRoleDirectionChange:marshal(os)
  os:marshalInt32(self.direction)
end
function CRoleDirectionChange:unmarshal(os)
  self.direction = os:unmarshalInt32()
end
function CRoleDirectionChange:sizepolicy(size)
  return size <= 65535
end
return CRoleDirectionChange
