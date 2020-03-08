local SSynMemberJoinFightState = class("SSynMemberJoinFightState")
SSynMemberJoinFightState.TYPEID = 12592149
function SSynMemberJoinFightState:ctor(roleId, roleName, repResult)
  self.id = 12592149
  self.roleId = roleId or nil
  self.roleName = roleName or nil
  self.repResult = repResult or nil
end
function SSynMemberJoinFightState:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalString(self.roleName)
  os:marshalInt32(self.repResult)
end
function SSynMemberJoinFightState:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.roleName = os:unmarshalString()
  self.repResult = os:unmarshalInt32()
end
function SSynMemberJoinFightState:sizepolicy(size)
  return size <= 65535
end
return SSynMemberJoinFightState
