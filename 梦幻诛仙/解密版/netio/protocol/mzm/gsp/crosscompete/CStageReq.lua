local CStageReq = class("CStageReq")
CStageReq.TYPEID = 12616747
function CStageReq:ctor()
  self.id = 12616747
end
function CStageReq:marshal(os)
end
function CStageReq:unmarshal(os)
end
function CStageReq:sizepolicy(size)
  return size <= 65535
end
return CStageReq
