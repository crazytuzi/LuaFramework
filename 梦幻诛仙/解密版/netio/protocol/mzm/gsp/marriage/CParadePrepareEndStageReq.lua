local CParadePrepareEndStageReq = class("CParadePrepareEndStageReq")
CParadePrepareEndStageReq.TYPEID = 12599860
function CParadePrepareEndStageReq:ctor()
  self.id = 12599860
end
function CParadePrepareEndStageReq:marshal(os)
end
function CParadePrepareEndStageReq:unmarshal(os)
end
function CParadePrepareEndStageReq:sizepolicy(size)
  return size <= 65535
end
return CParadePrepareEndStageReq
