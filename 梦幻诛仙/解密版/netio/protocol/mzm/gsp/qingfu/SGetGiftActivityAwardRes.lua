local SGetGiftActivityAwardRes = class("SGetGiftActivityAwardRes")
SGetGiftActivityAwardRes.TYPEID = 12588826
function SGetGiftActivityAwardRes:ctor(activity_id, gift_bag_id, remain_count, buy_num)
  self.id = 12588826
  self.activity_id = activity_id or nil
  self.gift_bag_id = gift_bag_id or nil
  self.remain_count = remain_count or nil
  self.buy_num = buy_num or nil
end
function SGetGiftActivityAwardRes:marshal(os)
  os:marshalInt32(self.activity_id)
  os:marshalInt32(self.gift_bag_id)
  os:marshalInt32(self.remain_count)
  os:marshalInt32(self.buy_num)
end
function SGetGiftActivityAwardRes:unmarshal(os)
  self.activity_id = os:unmarshalInt32()
  self.gift_bag_id = os:unmarshalInt32()
  self.remain_count = os:unmarshalInt32()
  self.buy_num = os:unmarshalInt32()
end
function SGetGiftActivityAwardRes:sizepolicy(size)
  return size <= 65535
end
return SGetGiftActivityAwardRes
