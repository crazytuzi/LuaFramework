local SBrocastYaoShouItem = class("SBrocastYaoShouItem")
SBrocastYaoShouItem.TYPEID = 12587582
function SBrocastYaoShouItem:ctor(roleid, roleName, itemid2count)
  self.id = 12587582
  self.roleid = roleid or nil
  self.roleName = roleName or nil
  self.itemid2count = itemid2count or {}
end
function SBrocastYaoShouItem:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalString(self.roleName)
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
function SBrocastYaoShouItem:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.roleName = os:unmarshalString()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.itemid2count[k] = v
  end
end
function SBrocastYaoShouItem:sizepolicy(size)
  return size <= 65535
end
return SBrocastYaoShouItem
