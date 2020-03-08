local CTryFight = class("CTryFight")
CTryFight.TYPEID = 12621573
function CTryFight:ctor(passiveRoleId)
  self.id = 12621573
  self.passiveRoleId = passiveRoleId or nil
end
function CTryFight:marshal(os)
  os:marshalInt64(self.passiveRoleId)
end
function CTryFight:unmarshal(os)
  self.passiveRoleId = os:unmarshalInt64()
end
function CTryFight:sizepolicy(size)
  return size <= 65535
end
return CTryFight
