local CParadeRobStageReq = class("CParadeRobStageReq")
CParadeRobStageReq.TYPEID = 12599848
function CParadeRobStageReq:ctor()
  self.id = 12599848
end
function CParadeRobStageReq:marshal(os)
end
function CParadeRobStageReq:unmarshal(os)
end
function CParadeRobStageReq:sizepolicy(size)
  return size <= 65535
end
return CParadeRobStageReq
