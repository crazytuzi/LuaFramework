local CCreateSwornReq = class("CCreateSwornReq")
CCreateSwornReq.TYPEID = 12597766
function CCreateSwornReq:ctor()
  self.id = 12597766
end
function CCreateSwornReq:marshal(os)
end
function CCreateSwornReq:unmarshal(os)
end
function CCreateSwornReq:sizepolicy(size)
  return size <= 65535
end
return CCreateSwornReq
