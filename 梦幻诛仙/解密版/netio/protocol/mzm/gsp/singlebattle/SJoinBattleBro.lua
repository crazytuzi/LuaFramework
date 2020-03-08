local SJoinBattleBro = class("SJoinBattleBro")
SJoinBattleBro.TYPEID = 12621574
function SJoinBattleBro:ctor(roleId)
  self.id = 12621574
  self.roleId = roleId or nil
end
function SJoinBattleBro:marshal(os)
  os:marshalInt64(self.roleId)
end
function SJoinBattleBro:unmarshal(os)
  self.roleId = os:unmarshalInt64()
end
function SJoinBattleBro:sizepolicy(size)
  return size <= 65535
end
return SJoinBattleBro
