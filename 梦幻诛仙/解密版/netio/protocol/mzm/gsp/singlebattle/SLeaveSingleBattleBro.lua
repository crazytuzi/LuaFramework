local SLeaveSingleBattleBro = class("SLeaveSingleBattleBro")
SLeaveSingleBattleBro.TYPEID = 12621569
function SLeaveSingleBattleBro:ctor(roleId)
  self.id = 12621569
  self.roleId = roleId or nil
end
function SLeaveSingleBattleBro:marshal(os)
  os:marshalInt64(self.roleId)
end
function SLeaveSingleBattleBro:unmarshal(os)
  self.roleId = os:unmarshalInt64()
end
function SLeaveSingleBattleBro:sizepolicy(size)
  return size <= 65535
end
return SLeaveSingleBattleBro
