local CUseMiFangReq = class("CUseMiFangReq")
CUseMiFangReq.TYPEID = 12589919
function CUseMiFangReq:ctor()
  self.id = 12589919
end
function CUseMiFangReq:marshal(os)
end
function CUseMiFangReq:unmarshal(os)
end
function CUseMiFangReq:sizepolicy(size)
  return size <= 65535
end
return CUseMiFangReq
