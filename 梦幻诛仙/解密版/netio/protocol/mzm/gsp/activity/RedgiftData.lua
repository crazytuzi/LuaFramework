local OctetsStream = require("netio.OctetsStream")
local RedgiftData = class("RedgiftData")
RedgiftData.MONEY_TYPE_YUANBAO = 0
RedgiftData.MONEY_TYPE_GOLD = 1
RedgiftData.MONEY_TYPE_SILVER = 2
function RedgiftData:ctor(awardMoney)
  self.awardMoney = awardMoney or {}
end
function RedgiftData:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.awardMoney) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.awardMoney) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function RedgiftData:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.awardMoney[k] = v
  end
end
return RedgiftData
