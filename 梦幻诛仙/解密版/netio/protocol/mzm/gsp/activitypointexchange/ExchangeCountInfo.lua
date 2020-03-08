local OctetsStream = require("netio.OctetsStream")
local ExchangeCountInfo = class("ExchangeCountInfo")
function ExchangeCountInfo:ctor(cfgId2available, exchangeCountResetTimeStamp)
  self.cfgId2available = cfgId2available or {}
  self.exchangeCountResetTimeStamp = exchangeCountResetTimeStamp or nil
end
function ExchangeCountInfo:marshal(os)
  do
    local _size_ = 0
    for _, _ in pairs(self.cfgId2available) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.cfgId2available) do
      os:marshalInt32(k)
      os:marshalInt32(v)
    end
  end
  os:marshalInt64(self.exchangeCountResetTimeStamp)
end
function ExchangeCountInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.cfgId2available[k] = v
  end
  self.exchangeCountResetTimeStamp = os:unmarshalInt64()
end
return ExchangeCountInfo
