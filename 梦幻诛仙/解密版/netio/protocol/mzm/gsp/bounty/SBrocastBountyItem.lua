local SBrocastBountyItem = class("SBrocastBountyItem")
SBrocastBountyItem.TYPEID = 12584200
function SBrocastBountyItem:ctor(roleId, roleName, taskId, itemid2count)
  self.id = 12584200
  self.roleId = roleId or nil
  self.roleName = roleName or nil
  self.taskId = taskId or nil
  self.itemid2count = itemid2count or {}
end
function SBrocastBountyItem:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalString(self.roleName)
  os:marshalInt32(self.taskId)
  local _size_ = 0
  for _, _ in pairs(self.itemid2count) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.itemid2count) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SBrocastBountyItem:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.roleName = os:unmarshalString()
  self.taskId = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.itemid2count[k] = v
  end
end
function SBrocastBountyItem:sizepolicy(size)
  return size <= 65535
end
return SBrocastBountyItem
