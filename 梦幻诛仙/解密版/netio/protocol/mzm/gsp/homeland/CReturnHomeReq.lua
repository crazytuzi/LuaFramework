local CReturnHomeReq = class("CReturnHomeReq")
CReturnHomeReq.TYPEID = 12605478
function CReturnHomeReq:ctor()
  self.id = 12605478
end
function CReturnHomeReq:marshal(os)
end
function CReturnHomeReq:unmarshal(os)
end
function CReturnHomeReq:sizepolicy(size)
  return size <= 65535
end
return CReturnHomeReq
