local CSetCardInvisibleReq = class("CSetCardInvisibleReq")
CSetCardInvisibleReq.TYPEID = 12624406
function CSetCardInvisibleReq:ctor()
  self.id = 12624406
end
function CSetCardInvisibleReq:marshal(os)
end
function CSetCardInvisibleReq:unmarshal(os)
end
function CSetCardInvisibleReq:sizepolicy(size)
  return size <= 65535
end
return CSetCardInvisibleReq
