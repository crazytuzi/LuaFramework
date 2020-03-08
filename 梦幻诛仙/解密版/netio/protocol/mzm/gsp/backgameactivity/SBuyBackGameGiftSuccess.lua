local SBuyBackGameGiftSuccess = class("SBuyBackGameGiftSuccess")
SBuyBackGameGiftSuccess.TYPEID = 12620546
function SBuyBackGameGiftSuccess:ctor(gift_id, buy_count)
  self.id = 12620546
  self.gift_id = gift_id or nil
  self.buy_count = buy_count or nil
end
function SBuyBackGameGiftSuccess:marshal(os)
  os:marshalInt32(self.gift_id)
  os:marshalInt32(self.buy_count)
end
function SBuyBackGameGiftSuccess:unmarshal(os)
  self.gift_id = os:unmarshalInt32()
  self.buy_count = os:unmarshalInt32()
end
function SBuyBackGameGiftSuccess:sizepolicy(size)
  return size <= 65535
end
return SBuyBackGameGiftSuccess
