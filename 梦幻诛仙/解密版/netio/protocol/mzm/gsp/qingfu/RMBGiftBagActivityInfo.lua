local OctetsStream = require("netio.OctetsStream")
local RMBGiftBagActivityInfo = class("RMBGiftBagActivityInfo")
function RMBGiftBagActivityInfo:ctor(opendays, tiers)
  self.opendays = opendays or nil
  self.tiers = tiers or {}
end
function RMBGiftBagActivityInfo:marshal(os)
  os:marshalInt32(self.opendays)
  local _size_ = 0
  for _, _ in pairs(self.tiers) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.tiers) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function RMBGiftBagActivityInfo:unmarshal(os)
  self.opendays = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.qingfu.RMBGiftBagTierInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.tiers[k] = v
  end
end
return RMBGiftBagActivityInfo
