local SJoinChatRoomRsp = class("SJoinChatRoomRsp")
SJoinChatRoomRsp.TYPEID = 12585250
SJoinChatRoomRsp.SUCCESS = 0
SJoinChatRoomRsp.ERROR_NO_PROVINCE = -1
SJoinChatRoomRsp.ERROR_CHAT_SERVER_NETWORK_ERROR = -2
SJoinChatRoomRsp.ERROR_OTHERS = -3
function SJoinChatRoomRsp:ctor(retcode, province)
  self.id = 12585250
  self.retcode = retcode or nil
  self.province = province or nil
end
function SJoinChatRoomRsp:marshal(os)
  os:marshalInt32(self.retcode)
  os:marshalInt32(self.province)
end
function SJoinChatRoomRsp:unmarshal(os)
  self.retcode = os:unmarshalInt32()
  self.province = os:unmarshalInt32()
end
function SJoinChatRoomRsp:sizepolicy(size)
  return size <= 65535
end
return SJoinChatRoomRsp
