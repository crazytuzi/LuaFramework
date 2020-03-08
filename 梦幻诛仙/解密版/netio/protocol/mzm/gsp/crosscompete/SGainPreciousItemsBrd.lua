local SGainPreciousItemsBrd = class("SGainPreciousItemsBrd")
SGainPreciousItemsBrd.TYPEID = 12616710
function SGainPreciousItemsBrd:ctor(roleid, name, faction, items)
  self.id = 12616710
  self.roleid = roleid or nil
  self.name = name or nil
  self.faction = faction or nil
  self.items = items or {}
end
function SGainPreciousItemsBrd:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalString(self.name)
  os:marshalString(self.faction)
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
function SGainPreciousItemsBrd:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.name = os:unmarshalString()
  self.faction = os:unmarshalString()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.items[k] = v
  end
end
function SGainPreciousItemsBrd:sizepolicy(size)
  return size <= 65535
end
return SGainPreciousItemsBrd
