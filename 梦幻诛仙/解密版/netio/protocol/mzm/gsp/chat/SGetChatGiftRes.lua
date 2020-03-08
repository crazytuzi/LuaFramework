local SGetChatGiftRes = class("SGetChatGiftRes")
SGetChatGiftRes.TYPEID = 12585258
function SGetChatGiftRes:ctor(money, moneyType, channelType)
  self.id = 12585258
  self.money = money or nil
  self.moneyType = moneyType or nil
  self.channelType = channelType or nil
end
function SGetChatGiftRes:marshal(os)
  os:marshalInt32(self.money)
  os:marshalInt32(self.moneyType)
  os:marshalInt32(self.channelType)
end
function SGetChatGiftRes:unmarshal(os)
  self.money = os:unmarshalInt32()
  self.moneyType = os:unmarshalInt32()
  self.channelType = os:unmarshalInt32()
end
function SGetChatGiftRes:sizepolicy(size)
  return size <= 65535
end
return SGetChatGiftRes
