local SRoleDieBro = class("SRoleDieBro")
SRoleDieBro.TYPEID = 12621576
function SRoleDieBro:ctor(dieRoleId, killerId, reviveTime)
  self.id = 12621576
  self.dieRoleId = dieRoleId or nil
  self.killerId = killerId or nil
  self.reviveTime = reviveTime or nil
end
function SRoleDieBro:marshal(os)
  os:marshalInt64(self.dieRoleId)
  os:marshalInt64(self.killerId)
  os:marshalInt32(self.reviveTime)
end
function SRoleDieBro:unmarshal(os)
  self.dieRoleId = os:unmarshalInt64()
  self.killerId = os:unmarshalInt64()
  self.reviveTime = os:unmarshalInt32()
end
function SRoleDieBro:sizepolicy(size)
  return size <= 65535
end
return SRoleDieBro
