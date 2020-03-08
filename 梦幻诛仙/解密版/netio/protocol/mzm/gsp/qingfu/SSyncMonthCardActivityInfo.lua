local SSyncMonthCardActivityInfo = class("SSyncMonthCardActivityInfo")
SSyncMonthCardActivityInfo.TYPEID = 12588819
function SSyncMonthCardActivityInfo:ctor(activity_infos)
  self.id = 12588819
  self.activity_infos = activity_infos or {}
end
function SSyncMonthCardActivityInfo:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.activity_infos) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.activity_infos) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function SSyncMonthCardActivityInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.qingfu.MonthCardActivityInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.activity_infos[k] = v
  end
end
function SSyncMonthCardActivityInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncMonthCardActivityInfo
