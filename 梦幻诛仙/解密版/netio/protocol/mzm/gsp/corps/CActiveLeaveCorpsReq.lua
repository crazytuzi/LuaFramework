local CActiveLeaveCorpsReq = class("CActiveLeaveCorpsReq")
CActiveLeaveCorpsReq.TYPEID = 12617478
function CActiveLeaveCorpsReq:ctor()
  self.id = 12617478
end
function CActiveLeaveCorpsReq:marshal(os)
end
function CActiveLeaveCorpsReq:unmarshal(os)
end
function CActiveLeaveCorpsReq:sizepolicy(size)
  return size <= 65535
end
return CActiveLeaveCorpsReq
