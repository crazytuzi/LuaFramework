local CardInfo = require("netio.protocol.mzm.gsp.changemodelcard.CardInfo")
local SUnlockCardSuccess = class("SUnlockCardSuccess")
SUnlockCardSuccess.TYPEID = 12624397
function SUnlockCardSuccess:ctor(card_id, card_info)
  self.id = 12624397
  self.card_id = card_id or nil
  self.card_info = card_info or CardInfo.new()
end
function SUnlockCardSuccess:marshal(os)
  os:marshalInt64(self.card_id)
  self.card_info:marshal(os)
end
function SUnlockCardSuccess:unmarshal(os)
  self.card_id = os:unmarshalInt64()
  self.card_info = CardInfo.new()
  self.card_info:unmarshal(os)
end
function SUnlockCardSuccess:sizepolicy(size)
  return size <= 65535
end
return SUnlockCardSuccess
