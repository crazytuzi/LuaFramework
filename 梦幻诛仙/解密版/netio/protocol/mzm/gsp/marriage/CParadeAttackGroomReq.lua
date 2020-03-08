local CParadeAttackGroomReq = class("CParadeAttackGroomReq")
CParadeAttackGroomReq.TYPEID = 12599852
function CParadeAttackGroomReq:ctor()
  self.id = 12599852
end
function CParadeAttackGroomReq:marshal(os)
end
function CParadeAttackGroomReq:unmarshal(os)
end
function CParadeAttackGroomReq:sizepolicy(size)
  return size <= 65535
end
return CParadeAttackGroomReq
