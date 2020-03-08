local CParadeAttackBrideReq = class("CParadeAttackBrideReq")
CParadeAttackBrideReq.TYPEID = 12599849
function CParadeAttackBrideReq:ctor()
  self.id = 12599849
end
function CParadeAttackBrideReq:marshal(os)
end
function CParadeAttackBrideReq:unmarshal(os)
end
function CParadeAttackBrideReq:sizepolicy(size)
  return size <= 65535
end
return CParadeAttackBrideReq
