local CDrawAwardFinishReq = class("CDrawAwardFinishReq")
CDrawAwardFinishReq.TYPEID = 12630021
function CDrawAwardFinishReq:ctor()
  self.id = 12630021
end
function CDrawAwardFinishReq:marshal(os)
end
function CDrawAwardFinishReq:unmarshal(os)
end
function CDrawAwardFinishReq:sizepolicy(size)
  return size <= 65535
end
return CDrawAwardFinishReq
