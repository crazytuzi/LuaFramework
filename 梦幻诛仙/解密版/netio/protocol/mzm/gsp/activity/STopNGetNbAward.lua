local STopNGetNbAward = class("STopNGetNbAward")
STopNGetNbAward.TYPEID = 12587593
function STopNGetNbAward:ctor(roleId, rank, roleName, items)
  self.id = 12587593
  self.roleId = roleId or nil
  self.rank = rank or nil
  self.roleName = roleName or nil
  self.items = items or {}
end
function STopNGetNbAward:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalInt32(self.rank)
  os:marshalString(self.roleName)
  local _size_ = 0
  for _, _ in pairs(self.items) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.items) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function STopNGetNbAward:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.rank = os:unmarshalInt32()
  self.roleName = os:unmarshalString()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.items[k] = v
  end
end
function STopNGetNbAward:sizepolicy(size)
  return size <= 65535
end
return STopNGetNbAward
