local SSyncRoleStatusChange = class("SSyncRoleStatusChange")
SSyncRoleStatusChange.TYPEID = 12590899
function SSyncRoleStatusChange:ctor(roleId, removeList, addList)
  self.id = 12590899
  self.roleId = roleId or nil
  self.removeList = removeList or {}
  self.addList = addList or {}
end
function SSyncRoleStatusChange:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalCompactUInt32(table.getn(self.removeList))
  for _, v in ipairs(self.removeList) do
    os:marshalInt32(v)
  end
  os:marshalCompactUInt32(table.getn(self.addList))
  for _, v in ipairs(self.addList) do
    os:marshalInt32(v)
  end
end
function SSyncRoleStatusChange:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.removeList, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.addList, v)
  end
end
function SSyncRoleStatusChange:sizepolicy(size)
  return size <= 65535
end
return SSyncRoleStatusChange
