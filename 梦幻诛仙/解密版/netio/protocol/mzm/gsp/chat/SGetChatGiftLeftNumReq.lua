local SGetChatGiftLeftNumReq = class("SGetChatGiftLeftNumReq")
SGetChatGiftLeftNumReq.TYPEID = 12585267
function SGetChatGiftLeftNumReq:ctor(leftNum)
  self.id = 12585267
  self.leftNum = leftNum or nil
end
function SGetChatGiftLeftNumReq:marshal(os)
  os:marshalInt32(self.leftNum)
end
function SGetChatGiftLeftNumReq:unmarshal(os)
  self.leftNum = os:unmarshalInt32()
end
function SGetChatGiftLeftNumReq:sizepolicy(size)
  return size <= 65535
end
return SGetChatGiftLeftNumReq
