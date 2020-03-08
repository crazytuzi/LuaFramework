local SGainPreciousItemBrd = class("SGainPreciousItemBrd")
SGainPreciousItemBrd.TYPEID = 12598296
function SGainPreciousItemBrd:ctor(name, items)
  self.id = 12598296
  self.name = name or nil
  self.items = items or {}
end
function SGainPreciousItemBrd:marshal(os)
  os:marshalString(self.name)
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
function SGainPreciousItemBrd:unmarshal(os)
  self.name = os:unmarshalString()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.items[k] = v
  end
end
function SGainPreciousItemBrd:sizepolicy(size)
  return size <= 65535
end
return SGainPreciousItemBrd
