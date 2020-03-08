local SSyncVigorList = class("SSyncVigorList")
SSyncVigorList.TYPEID = 12586003
function SSyncVigorList:ctor(vigorMap)
  self.id = 12586003
  self.vigorMap = vigorMap or {}
end
function SSyncVigorList:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.vigorMap) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.vigorMap) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function SSyncVigorList:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.role.ActivityVigor")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.vigorMap[k] = v
  end
end
function SSyncVigorList:sizepolicy(size)
  return size <= 65535
end
return SSyncVigorList
