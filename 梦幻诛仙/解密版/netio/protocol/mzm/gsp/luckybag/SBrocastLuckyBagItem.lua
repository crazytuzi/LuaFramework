local SBrocastLuckyBagItem = class("SBrocastLuckyBagItem")
SBrocastLuckyBagItem.TYPEID = 12607492
function SBrocastLuckyBagItem:ctor(roleid, role_name, map_item_cfgid, items)
  self.id = 12607492
  self.roleid = roleid or nil
  self.role_name = role_name or nil
  self.map_item_cfgid = map_item_cfgid or nil
  self.items = items or {}
end
function SBrocastLuckyBagItem:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalOctets(self.role_name)
  os:marshalInt32(self.map_item_cfgid)
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
function SBrocastLuckyBagItem:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.role_name = os:unmarshalOctets()
  self.map_item_cfgid = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.items[k] = v
  end
end
function SBrocastLuckyBagItem:sizepolicy(size)
  return size <= 65535
end
return SBrocastLuckyBagItem
