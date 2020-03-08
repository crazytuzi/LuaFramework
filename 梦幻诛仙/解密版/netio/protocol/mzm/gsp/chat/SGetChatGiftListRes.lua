local SGetChatGiftListRes = class("SGetChatGiftListRes")
SGetChatGiftListRes.TYPEID = 12585262
function SGetChatGiftListRes:ctor(chatgiftlist)
  self.id = 12585262
  self.chatgiftlist = chatgiftlist or {}
end
function SGetChatGiftListRes:marshal(os)
  os:marshalCompactUInt32(table.getn(self.chatgiftlist))
  for _, v in ipairs(self.chatgiftlist) do
    v:marshal(os)
  end
end
function SGetChatGiftListRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.chat.GetChatGiftSimpleInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.chatgiftlist, v)
  end
end
function SGetChatGiftListRes:sizepolicy(size)
  return size <= 65535
end
return SGetChatGiftListRes
