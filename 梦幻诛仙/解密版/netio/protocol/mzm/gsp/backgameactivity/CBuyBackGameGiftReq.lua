local CBuyBackGameGiftReq = class("CBuyBackGameGiftReq")
CBuyBackGameGiftReq.TYPEID = 12620555
function CBuyBackGameGiftReq:ctor(gift_id, buy_count)
  self.id = 12620555
  self.gift_id = gift_id or nil
  self.buy_count = buy_count or nil
end
function CBuyBackGameGiftReq:marshal(os)
  os:marshalInt32(self.gift_id)
  os:marshalInt32(self.buy_count)
end
function CBuyBackGameGiftReq:unmarshal(os)
  self.gift_id = os:unmarshalInt32()
  self.buy_count = os:unmarshalInt32()
end
function CBuyBackGameGiftReq:sizepolicy(size)
  return size <= 65535
end
return CBuyBackGameGiftReq
