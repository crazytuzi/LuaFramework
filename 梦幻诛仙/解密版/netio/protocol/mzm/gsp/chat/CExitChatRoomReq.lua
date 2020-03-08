local CExitChatRoomReq = class("CExitChatRoomReq")
CExitChatRoomReq.TYPEID = 12585252
function CExitChatRoomReq:ctor()
  self.id = 12585252
end
function CExitChatRoomReq:marshal(os)
end
function CExitChatRoomReq:unmarshal(os)
end
function CExitChatRoomReq:sizepolicy(size)
  return size <= 65535
end
return CExitChatRoomReq
