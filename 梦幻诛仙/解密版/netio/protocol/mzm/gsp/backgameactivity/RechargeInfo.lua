local OctetsStream = require("netio.OctetsStream")
local RechargeInfo = class("RechargeInfo")
function RechargeInfo:ctor(accumulateRechargeCount, manekiTokenCfgId2count)
  self.accumulateRechargeCount = accumulateRechargeCount or nil
  self.manekiTokenCfgId2count = manekiTokenCfgId2count or {}
end
function RechargeInfo:marshal(os)
  os:marshalInt64(self.accumulateRechargeCount)
  local _size_ = 0
  for _, _ in pairs(self.manekiTokenCfgId2count) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.manekiTokenCfgId2count) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function RechargeInfo:unmarshal(os)
  self.accumulateRechargeCount = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.manekiTokenCfgId2count[k] = v
  end
end
return RechargeInfo
