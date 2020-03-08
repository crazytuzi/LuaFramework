local CRaceStatusReq = class("CRaceStatusReq")
CRaceStatusReq.TYPEID = 12602121
function CRaceStatusReq:ctor()
  self.id = 12602121
end
function CRaceStatusReq:marshal(os)
end
function CRaceStatusReq:unmarshal(os)
end
function CRaceStatusReq:sizepolicy(size)
  return size <= 65535
end
return CRaceStatusReq
