local SSyncExtraReward = class("SSyncExtraReward")
SSyncExtraReward.TYPEID = 12594690
function SSyncExtraReward:ctor(awardList)
  self.id = 12594690
  self.awardList = awardList or {}
end
function SSyncExtraReward:marshal(os)
  os:marshalCompactUInt32(table.getn(self.awardList))
  for _, v in ipairs(self.awardList) do
    v:marshal(os)
  end
end
function SSyncExtraReward:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.question.RewardItem")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.awardList, v)
  end
end
function SSyncExtraReward:sizepolicy(size)
  return size <= 65535
end
return SSyncExtraReward
