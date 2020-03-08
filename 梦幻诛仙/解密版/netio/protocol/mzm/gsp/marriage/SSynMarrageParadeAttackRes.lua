local SSynMarrageParadeAttackRes = class("SSynMarrageParadeAttackRes")
SSynMarrageParadeAttackRes.TYPEID = 12599863
function SSynMarrageParadeAttackRes:ctor(paradeRoleType, attackedState)
  self.id = 12599863
  self.paradeRoleType = paradeRoleType or nil
  self.attackedState = attackedState or nil
end
function SSynMarrageParadeAttackRes:marshal(os)
  os:marshalInt32(self.paradeRoleType)
  os:marshalInt32(self.attackedState)
end
function SSynMarrageParadeAttackRes:unmarshal(os)
  self.paradeRoleType = os:unmarshalInt32()
  self.attackedState = os:unmarshalInt32()
end
function SSynMarrageParadeAttackRes:sizepolicy(size)
  return size <= 65535
end
return SSynMarrageParadeAttackRes
