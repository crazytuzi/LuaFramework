local SSyncRoleCompetition = class("SSyncRoleCompetition")
SSyncRoleCompetition.TYPEID = 12598530
function SSyncRoleCompetition:ctor(action_point)
  self.id = 12598530
  self.action_point = action_point or nil
end
function SSyncRoleCompetition:marshal(os)
  os:marshalInt32(self.action_point)
end
function SSyncRoleCompetition:unmarshal(os)
  self.action_point = os:unmarshalInt32()
end
function SSyncRoleCompetition:sizepolicy(size)
  return size <= 65535
end
return SSyncRoleCompetition
