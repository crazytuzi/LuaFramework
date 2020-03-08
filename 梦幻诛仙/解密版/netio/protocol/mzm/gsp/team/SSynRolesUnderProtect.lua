local SSynRolesUnderProtect = class("SSynRolesUnderProtect")
SSynRolesUnderProtect.TYPEID = 12588344
function SSynRolesUnderProtect:ctor(rolesUnderProtect)
  self.id = 12588344
  self.rolesUnderProtect = rolesUnderProtect or {}
end
function SSynRolesUnderProtect:marshal(os)
  os:marshalCompactUInt32(table.getn(self.rolesUnderProtect))
  for _, v in ipairs(self.rolesUnderProtect) do
    os:marshalInt64(v)
  end
end
function SSynRolesUnderProtect:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    table.insert(self.rolesUnderProtect, v)
  end
end
function SSynRolesUnderProtect:sizepolicy(size)
  return size <= 65535
end
return SSynRolesUnderProtect
