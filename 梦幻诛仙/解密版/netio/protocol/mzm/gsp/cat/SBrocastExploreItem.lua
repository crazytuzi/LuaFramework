local SBrocastExploreItem = class("SBrocastExploreItem")
SBrocastExploreItem.TYPEID = 12605721
function SBrocastExploreItem:ctor(roleid, role_name, items)
  self.id = 12605721
  self.roleid = roleid or nil
  self.role_name = role_name or nil
  self.items = items or {}
end
function SBrocastExploreItem:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalOctets(self.role_name)
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
function SBrocastExploreItem:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.role_name = os:unmarshalOctets()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.items[k] = v
  end
end
function SBrocastExploreItem:sizepolicy(size)
  return size <= 65535
end
return SBrocastExploreItem
