local SSynQingProgress = class("SSynQingProgress")
SSynQingProgress.TYPEID = 12590338
function SSynQingProgress:ctor(type2Progress)
  self.id = 12590338
  self.type2Progress = type2Progress or {}
end
function SSynQingProgress:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.type2Progress) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.type2Progress) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function SSynQingProgress:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.qingyunzhi.Progress")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.type2Progress[k] = v
  end
end
function SSynQingProgress:sizepolicy(size)
  return size <= 65535
end
return SSynQingProgress
