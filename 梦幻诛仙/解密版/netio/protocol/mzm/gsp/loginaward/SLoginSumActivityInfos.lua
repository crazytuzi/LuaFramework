local SLoginSumActivityInfos = class("SLoginSumActivityInfos")
SLoginSumActivityInfos.TYPEID = 12604679
function SLoginSumActivityInfos:ctor(activityInfos)
  self.id = 12604679
  self.activityInfos = activityInfos or {}
end
function SLoginSumActivityInfos:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.activityInfos) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.activityInfos) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function SLoginSumActivityInfos:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.loginaward.LoginSumActivityInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.activityInfos[k] = v
  end
end
function SLoginSumActivityInfos:sizepolicy(size)
  return size <= 65535
end
return SLoginSumActivityInfos
