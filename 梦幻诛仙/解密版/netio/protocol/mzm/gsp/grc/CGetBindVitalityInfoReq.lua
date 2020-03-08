local CGetBindVitalityInfoReq = class("CGetBindVitalityInfoReq")
CGetBindVitalityInfoReq.TYPEID = 12600381
function CGetBindVitalityInfoReq:ctor()
  self.id = 12600381
end
function CGetBindVitalityInfoReq:marshal(os)
end
function CGetBindVitalityInfoReq:unmarshal(os)
end
function CGetBindVitalityInfoReq:sizepolicy(size)
  return size <= 65535
end
return CGetBindVitalityInfoReq
