local CMarrageParadeAttackReq = class("CMarrageParadeAttackReq")
CMarrageParadeAttackReq.TYPEID = 12599862
function CMarrageParadeAttackReq:ctor(paradeRoleType)
  self.id = 12599862
  self.paradeRoleType = paradeRoleType or nil
end
function CMarrageParadeAttackReq:marshal(os)
  os:marshalInt32(self.paradeRoleType)
end
function CMarrageParadeAttackReq:unmarshal(os)
  self.paradeRoleType = os:unmarshalInt32()
end
function CMarrageParadeAttackReq:sizepolicy(size)
  return size <= 65535
end
return CMarrageParadeAttackReq
