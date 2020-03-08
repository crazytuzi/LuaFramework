local SSynOwnFurnitureRes = class("SSynOwnFurnitureRes")
SSynOwnFurnitureRes.TYPEID = 12605443
function SSynOwnFurnitureRes:ctor(furnitures, court_yard_furnitures)
  self.id = 12605443
  self.furnitures = furnitures or {}
  self.court_yard_furnitures = court_yard_furnitures or {}
end
function SSynOwnFurnitureRes:marshal(os)
  do
    local _size_ = 0
    for _, _ in pairs(self.furnitures) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.furnitures) do
      os:marshalInt32(k)
      v:marshal(os)
    end
  end
  local _size_ = 0
  for _, _ in pairs(self.court_yard_furnitures) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.court_yard_furnitures) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function SSynOwnFurnitureRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.homeland.FurnitureUuIds")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.furnitures[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.homeland.FurnitureUuIds")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.court_yard_furnitures[k] = v
  end
end
function SSynOwnFurnitureRes:sizepolicy(size)
  return size <= 65535
end
return SSynOwnFurnitureRes
