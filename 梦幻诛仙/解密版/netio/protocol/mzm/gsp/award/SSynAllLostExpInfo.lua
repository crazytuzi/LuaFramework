local SSynAllLostExpInfo = class("SSynAllLostExpInfo")
SSynAllLostExpInfo.TYPEID = 12583450
function SSynAllLostExpInfo:ctor(activityId2LostExpInfo)
  self.id = 12583450
  self.activityId2LostExpInfo = activityId2LostExpInfo or {}
end
function SSynAllLostExpInfo:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.activityId2LostExpInfo) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.activityId2LostExpInfo) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function SSynAllLostExpInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.award.LostExpInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.activityId2LostExpInfo[k] = v
  end
end
function SSynAllLostExpInfo:sizepolicy(size)
  return size <= 65535
end
return SSynAllLostExpInfo
