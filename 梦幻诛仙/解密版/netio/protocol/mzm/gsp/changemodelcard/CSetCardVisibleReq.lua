local CSetCardVisibleReq = class("CSetCardVisibleReq")
CSetCardVisibleReq.TYPEID = 12624414
function CSetCardVisibleReq:ctor()
  self.id = 12624414
end
function CSetCardVisibleReq:marshal(os)
end
function CSetCardVisibleReq:unmarshal(os)
end
function CSetCardVisibleReq:sizepolicy(size)
  return size <= 65535
end
return CSetCardVisibleReq
