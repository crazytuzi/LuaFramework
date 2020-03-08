local GiftBagId2Count = require("netio.protocol.mzm.gsp.qingfu.GiftBagId2Count")
local SSynGiftActivityAwardRes = class("SSynGiftActivityAwardRes")
SSynGiftActivityAwardRes.TYPEID = 12588828
function SSynGiftActivityAwardRes:ctor(activity_id, gift_bag_id_2_remain_count)
  self.id = 12588828
  self.activity_id = activity_id or nil
  self.gift_bag_id_2_remain_count = gift_bag_id_2_remain_count or GiftBagId2Count.new()
end
function SSynGiftActivityAwardRes:marshal(os)
  os:marshalInt32(self.activity_id)
  self.gift_bag_id_2_remain_count:marshal(os)
end
function SSynGiftActivityAwardRes:unmarshal(os)
  self.activity_id = os:unmarshalInt32()
  self.gift_bag_id_2_remain_count = GiftBagId2Count.new()
  self.gift_bag_id_2_remain_count:unmarshal(os)
end
function SSynGiftActivityAwardRes:sizepolicy(size)
  return size <= 65535
end
return SSynGiftActivityAwardRes
