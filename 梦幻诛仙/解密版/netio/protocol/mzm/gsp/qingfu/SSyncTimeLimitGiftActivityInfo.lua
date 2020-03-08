local SSyncTimeLimitGiftActivityInfo = class("SSyncTimeLimitGiftActivityInfo")
SSyncTimeLimitGiftActivityInfo.TYPEID = 12588825
function SSyncTimeLimitGiftActivityInfo:ctor(activity_id_2_gift_info)
  self.id = 12588825
  self.activity_id_2_gift_info = activity_id_2_gift_info or {}
end
function SSyncTimeLimitGiftActivityInfo:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.activity_id_2_gift_info) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.activity_id_2_gift_info) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function SSyncTimeLimitGiftActivityInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.qingfu.GiftBagId2Count")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.activity_id_2_gift_info[k] = v
  end
end
function SSyncTimeLimitGiftActivityInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncTimeLimitGiftActivityInfo
