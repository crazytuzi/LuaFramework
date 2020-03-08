local CGetOfflineChatContentsReq = class("CGetOfflineChatContentsReq")
CGetOfflineChatContentsReq.TYPEID = 12585278
function CGetOfflineChatContentsReq:ctor(channel_type)
  self.id = 12585278
  self.channel_type = channel_type or nil
end
function CGetOfflineChatContentsReq:marshal(os)
  os:marshalInt32(self.channel_type)
end
function CGetOfflineChatContentsReq:unmarshal(os)
  self.channel_type = os:unmarshalInt32()
end
function CGetOfflineChatContentsReq:sizepolicy(size)
  return size <= 65535
end
return CGetOfflineChatContentsReq
