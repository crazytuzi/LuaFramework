local SExitChatRoomRsp = class("SExitChatRoomRsp")
SExitChatRoomRsp.TYPEID = 12585251
SExitChatRoomRsp.SUCCESS = 0
SExitChatRoomRsp.ERROR_NO_JOIN_ROOM = -1
SExitChatRoomRsp.ERROR_CHAT_SERVER_NETWORK_ERROR = -2
SExitChatRoomRsp.ERROR_OTHERS = -3
function SExitChatRoomRsp:ctor(retcode)
  self.id = 12585251
  self.retcode = retcode or nil
end
function SExitChatRoomRsp:marshal(os)
  os:marshalInt32(self.retcode)
end
function SExitChatRoomRsp:unmarshal(os)
  self.retcode = os:unmarshalInt32()
end
function SExitChatRoomRsp:sizepolicy(size)
  return size <= 65535
end
return SExitChatRoomRsp
