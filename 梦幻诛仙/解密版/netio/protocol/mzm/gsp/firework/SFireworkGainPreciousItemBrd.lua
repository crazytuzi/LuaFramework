local SFireworkGainPreciousItemBrd = class("SFireworkGainPreciousItemBrd")
SFireworkGainPreciousItemBrd.TYPEID = 12625159
function SFireworkGainPreciousItemBrd:ctor(name, items)
  self.id = 12625159
  self.name = name or nil
  self.items = items or {}
end
function SFireworkGainPreciousItemBrd:marshal(os)
  os:marshalOctets(self.name)
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
function SFireworkGainPreciousItemBrd:unmarshal(os)
  self.name = os:unmarshalOctets()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.items[k] = v
  end
end
function SFireworkGainPreciousItemBrd:sizepolicy(size)
  return size <= 65535
end
return SFireworkGainPreciousItemBrd
