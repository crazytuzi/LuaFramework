local OctetsStream = require("netio.OctetsStream")
local ExchangeActivityInfo = class("ExchangeActivityInfo")
function ExchangeActivityInfo:ctor(exchange_award_infos)
  self.exchange_award_infos = exchange_award_infos or {}
end
function ExchangeActivityInfo:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.exchange_award_infos) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.exchange_award_infos) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function ExchangeActivityInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.exchange_award_infos[k] = v
  end
end
return ExchangeActivityInfo
