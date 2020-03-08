local CAcceptBackGameExpTaskReq = class("CAcceptBackGameExpTaskReq")
CAcceptBackGameExpTaskReq.TYPEID = 12620563
function CAcceptBackGameExpTaskReq:ctor()
  self.id = 12620563
end
function CAcceptBackGameExpTaskReq:marshal(os)
end
function CAcceptBackGameExpTaskReq:unmarshal(os)
end
function CAcceptBackGameExpTaskReq:sizepolicy(size)
  return size <= 65535
end
return CAcceptBackGameExpTaskReq
