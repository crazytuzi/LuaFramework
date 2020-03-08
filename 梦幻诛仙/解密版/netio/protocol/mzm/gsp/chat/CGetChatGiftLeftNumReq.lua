local CGetChatGiftLeftNumReq = class("CGetChatGiftLeftNumReq")
CGetChatGiftLeftNumReq.TYPEID = 12585268
function CGetChatGiftLeftNumReq:ctor()
  self.id = 12585268
end
function CGetChatGiftLeftNumReq:marshal(os)
end
function CGetChatGiftLeftNumReq:unmarshal(os)
end
function CGetChatGiftLeftNumReq:sizepolicy(size)
  return size <= 65535
end
return CGetChatGiftLeftNumReq
