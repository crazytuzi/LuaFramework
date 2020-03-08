local CRecallAllReq = class("CRecallAllReq")
CRecallAllReq.TYPEID = 12588303
function CRecallAllReq:ctor()
  self.id = 12588303
end
function CRecallAllReq:marshal(os)
end
function CRecallAllReq:unmarshal(os)
end
function CRecallAllReq:sizepolicy(size)
  return size <= 65535
end
return CRecallAllReq
