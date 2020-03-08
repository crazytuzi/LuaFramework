local COuterDrawAwardFinishReq = class("COuterDrawAwardFinishReq")
COuterDrawAwardFinishReq.TYPEID = 12622865
function COuterDrawAwardFinishReq:ctor()
  self.id = 12622865
end
function COuterDrawAwardFinishReq:marshal(os)
end
function COuterDrawAwardFinishReq:unmarshal(os)
end
function COuterDrawAwardFinishReq:sizepolicy(size)
  return size <= 65535
end
return COuterDrawAwardFinishReq
