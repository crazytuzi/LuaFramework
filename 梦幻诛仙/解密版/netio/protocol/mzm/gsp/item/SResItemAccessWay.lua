local SResItemAccessWay = class("SResItemAccessWay")
SResItemAccessWay.TYPEID = 12584754
function SResItemAccessWay:ctor(itemAccessWay)
  self.id = 12584754
  self.itemAccessWay = itemAccessWay or {}
end
function SResItemAccessWay:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.itemAccessWay) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.itemAccessWay) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function SResItemAccessWay:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.item.AccessWayInfoList")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.itemAccessWay[k] = v
  end
end
function SResItemAccessWay:sizepolicy(size)
  return size <= 65535
end
return SResItemAccessWay
