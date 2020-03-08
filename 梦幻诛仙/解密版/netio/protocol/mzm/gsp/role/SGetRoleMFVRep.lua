local SGetRoleMFVRep = class("SGetRoleMFVRep")
SGetRoleMFVRep.TYPEID = 12586032
function SGetRoleMFVRep:ctor(roleIds, roleMFVInfo)
  self.id = 12586032
  self.roleIds = roleIds or {}
  self.roleMFVInfo = roleMFVInfo or {}
end
function SGetRoleMFVRep:marshal(os)
  os:marshalCompactUInt32(table.getn(self.roleIds))
  for _, v in ipairs(self.roleIds) do
    os:marshalInt64(v)
  end
  local _size_ = 0
  for _, _ in pairs(self.roleMFVInfo) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.roleMFVInfo) do
    os:marshalInt64(k)
    os:marshalInt32(v)
  end
end
function SGetRoleMFVRep:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    table.insert(self.roleIds, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local v = os:unmarshalInt32()
    self.roleMFVInfo[k] = v
  end
end
function SGetRoleMFVRep:sizepolicy(size)
  return size <= 65535
end
return SGetRoleMFVRep
