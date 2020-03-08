local CEndBandstandReq = class("CEndBandstandReq")
CEndBandstandReq.TYPEID = 12627973
function CEndBandstandReq:ctor()
  self.id = 12627973
end
function CEndBandstandReq:marshal(os)
end
function CEndBandstandReq:unmarshal(os)
end
function CEndBandstandReq:sizepolicy(size)
  return size <= 65535
end
return CEndBandstandReq
