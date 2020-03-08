local CTempLeaveReq = class("CTempLeaveReq")
CTempLeaveReq.TYPEID = 12588296
function CTempLeaveReq:ctor()
  self.id = 12588296
end
function CTempLeaveReq:marshal(os)
end
function CTempLeaveReq:unmarshal(os)
end
function CTempLeaveReq:sizepolicy(size)
  return size <= 65535
end
return CTempLeaveReq
