local SUnDisplayAllRes = class("SUnDisplayAllRes")
SUnDisplayAllRes.TYPEID = 12605469
function SUnDisplayAllRes:ctor(decFengshui, unDisplayFurnitures)
  self.id = 12605469
  self.decFengshui = decFengshui or nil
  self.unDisplayFurnitures = unDisplayFurnitures or {}
end
function SUnDisplayAllRes:marshal(os)
  os:marshalInt32(self.decFengshui)
  local _size_ = 0
  for _, _ in pairs(self.unDisplayFurnitures) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.unDisplayFurnitures) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function SUnDisplayAllRes:unmarshal(os)
  self.decFengshui = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.homeland.FurnitureUuIds")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.unDisplayFurnitures[k] = v
  end
end
function SUnDisplayAllRes:sizepolicy(size)
  return size <= 65535
end
return SUnDisplayAllRes
