local CJoinChatRoomReq = class("CJoinChatRoomReq")
CJoinChatRoomReq.TYPEID = 12585249
function CJoinChatRoomReq:ctor()
  self.id = 12585249
end
function CJoinChatRoomReq:marshal(os)
end
function CJoinChatRoomReq:unmarshal(os)
end
function CJoinChatRoomReq:sizepolicy(size)
  return size <= 65535
end
return CJoinChatRoomReq
