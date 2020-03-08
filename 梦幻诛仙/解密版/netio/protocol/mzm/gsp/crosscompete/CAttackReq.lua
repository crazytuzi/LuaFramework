local CAttackReq = class("CAttackReq")
CAttackReq.TYPEID = 12616715
function CAttackReq:ctor(target)
  self.id = 12616715
  self.target = target or nil
end
function CAttackReq:marshal(os)
  os:marshalInt64(self.target)
end
function CAttackReq:unmarshal(os)
  self.target = os:unmarshalInt64()
end
function CAttackReq:sizepolicy(size)
  return size <= 65535
end
return CAttackReq
