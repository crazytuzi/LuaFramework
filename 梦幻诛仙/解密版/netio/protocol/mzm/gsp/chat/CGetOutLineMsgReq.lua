local CGetOutLineMsgReq = class("CGetOutLineMsgReq")
CGetOutLineMsgReq.TYPEID = 12585238
function CGetOutLineMsgReq:ctor()
  self.id = 12585238
end
function CGetOutLineMsgReq:marshal(os)
end
function CGetOutLineMsgReq:unmarshal(os)
end
function CGetOutLineMsgReq:sizepolicy(size)
  return size <= 65535
end
return CGetOutLineMsgReq
