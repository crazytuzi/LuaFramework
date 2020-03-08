local CInnerDrawAwardFinishReq = class("CInnerDrawAwardFinishReq")
CInnerDrawAwardFinishReq.TYPEID = 12622864
function CInnerDrawAwardFinishReq:ctor()
  self.id = 12622864
end
function CInnerDrawAwardFinishReq:marshal(os)
end
function CInnerDrawAwardFinishReq:unmarshal(os)
end
function CInnerDrawAwardFinishReq:sizepolicy(size)
  return size <= 65535
end
return CInnerDrawAwardFinishReq
