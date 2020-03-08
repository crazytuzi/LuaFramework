local OctetsStream = require("netio.OctetsStream")
local FlopLotteryResult = class("FlopLotteryResult")
function FlopLotteryResult:ctor(index, awardIdList)
  self.index = index or nil
  self.awardIdList = awardIdList or {}
end
function FlopLotteryResult:marshal(os)
  os:marshalInt32(self.index)
  os:marshalCompactUInt32(table.getn(self.awardIdList))
  for _, v in ipairs(self.awardIdList) do
    v:marshal(os)
  end
end
function FlopLotteryResult:unmarshal(os)
  self.index = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.floplottery.RewardItem")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.awardIdList, v)
  end
end
return FlopLotteryResult
