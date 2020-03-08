local OctetsStream = require("netio.OctetsStream")
local BackGameActivityGiftInfo = class("BackGameActivityGiftInfo")
function BackGameActivityGiftInfo:ctor(gift_buy_count)
  self.gift_buy_count = gift_buy_count or {}
end
function BackGameActivityGiftInfo:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.gift_buy_count) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.gift_buy_count) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function BackGameActivityGiftInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.gift_buy_count[k] = v
  end
end
return BackGameActivityGiftInfo
