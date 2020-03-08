local CGetGiftActivityAwardReq = class("CGetGiftActivityAwardReq")
CGetGiftActivityAwardReq.TYPEID = 12588827
function CGetGiftActivityAwardReq:ctor(activity_id, gift_bag_id, remain_buy_count, buy_num)
  self.id = 12588827
  self.activity_id = activity_id or nil
  self.gift_bag_id = gift_bag_id or nil
  self.remain_buy_count = remain_buy_count or nil
  self.buy_num = buy_num or nil
end
function CGetGiftActivityAwardReq:marshal(os)
  os:marshalInt32(self.activity_id)
  os:marshalInt32(self.gift_bag_id)
  os:marshalInt32(self.remain_buy_count)
  os:marshalInt32(self.buy_num)
end
function CGetGiftActivityAwardReq:unmarshal(os)
  self.activity_id = os:unmarshalInt32()
  self.gift_bag_id = os:unmarshalInt32()
  self.remain_buy_count = os:unmarshalInt32()
  self.buy_num = os:unmarshalInt32()
end
function CGetGiftActivityAwardReq:sizepolicy(size)
  return size <= 65535
end
return CGetGiftActivityAwardReq
