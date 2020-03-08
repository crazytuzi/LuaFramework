local SAllBagInfo = class("SAllBagInfo")
SAllBagInfo.TYPEID = 12584724
function SAllBagInfo:ctor(bags)
  self.id = 12584724
  self.bags = bags or {}
end
function SAllBagInfo:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.bags) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.bags) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function SAllBagInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.item.BagInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.bags[k] = v
  end
end
function SAllBagInfo:sizepolicy(size)
  return size <= 131071
end
return SAllBagInfo
