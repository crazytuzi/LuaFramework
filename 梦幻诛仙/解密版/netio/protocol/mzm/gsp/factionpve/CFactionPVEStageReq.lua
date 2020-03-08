local CFactionPVEStageReq = class("CFactionPVEStageReq")
CFactionPVEStageReq.TYPEID = 12613653
function CFactionPVEStageReq:ctor()
  self.id = 12613653
end
function CFactionPVEStageReq:marshal(os)
end
function CFactionPVEStageReq:unmarshal(os)
end
function CFactionPVEStageReq:sizepolicy(size)
  return size <= 65535
end
return CFactionPVEStageReq
