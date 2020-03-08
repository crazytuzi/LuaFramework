local CUnDisplayAllReq = class("CUnDisplayAllReq")
CUnDisplayAllReq.TYPEID = 12605470
function CUnDisplayAllReq:ctor()
  self.id = 12605470
end
function CUnDisplayAllReq:marshal(os)
end
function CUnDisplayAllReq:unmarshal(os)
end
function CUnDisplayAllReq:sizepolicy(size)
  return size <= 65535
end
return CUnDisplayAllReq
