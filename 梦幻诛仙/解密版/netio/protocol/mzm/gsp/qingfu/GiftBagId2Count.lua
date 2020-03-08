local OctetsStream = require("netio.OctetsStream")
local GiftBagId2Count = class("GiftBagId2Count")
function GiftBagId2Count:ctor(gift_bag_id_2_remain_count)
  self.gift_bag_id_2_remain_count = gift_bag_id_2_remain_count or {}
end
function GiftBagId2Count:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.gift_bag_id_2_remain_count) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.gift_bag_id_2_remain_count) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function GiftBagId2Count:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.gift_bag_id_2_remain_count[k] = v
  end
end
return GiftBagId2Count
