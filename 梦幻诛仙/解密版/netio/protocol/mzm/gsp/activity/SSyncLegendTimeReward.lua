local SSyncLegendTimeReward = class("SSyncLegendTimeReward")
SSyncLegendTimeReward.TYPEID = 12587544
function SSyncLegendTimeReward:ctor(itemId, itemNum)
  self.id = 12587544
  self.itemId = itemId or nil
  self.itemNum = itemNum or nil
end
function SSyncLegendTimeReward:marshal(os)
  os:marshalInt32(self.itemId)
  os:marshalInt32(self.itemNum)
end
function SSyncLegendTimeReward:unmarshal(os)
  self.itemId = os:unmarshalInt32()
  self.itemNum = os:unmarshalInt32()
end
function SSyncLegendTimeReward:sizepolicy(size)
  return size <= 65535
end
return SSyncLegendTimeReward
