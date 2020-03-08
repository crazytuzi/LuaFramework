local SSyncFashionInfo = class("SSyncFashionInfo")
SSyncFashionInfo.TYPEID = 12609352
function SSyncFashionInfo:ctor(fashions)
  self.id = 12609352
  self.fashions = fashions or {}
end
function SSyncFashionInfo:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.fashions) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.fashions) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function SSyncFashionInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.children.FashionInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.fashions[k] = v
  end
end
function SSyncFashionInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncFashionInfo
