local SGetChatGiftAddBangGong = class("SGetChatGiftAddBangGong")
SGetChatGiftAddBangGong.TYPEID = 12585271
function SGetChatGiftAddBangGong:ctor(addBangGong)
  self.id = 12585271
  self.addBangGong = addBangGong or nil
end
function SGetChatGiftAddBangGong:marshal(os)
  os:marshalInt32(self.addBangGong)
end
function SGetChatGiftAddBangGong:unmarshal(os)
  self.addBangGong = os:unmarshalInt32()
end
function SGetChatGiftAddBangGong:sizepolicy(size)
  return size <= 65535
end
return SGetChatGiftAddBangGong
