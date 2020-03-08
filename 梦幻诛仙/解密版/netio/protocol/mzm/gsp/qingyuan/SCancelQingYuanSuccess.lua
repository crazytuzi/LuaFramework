local SCancelQingYuanSuccess = class("SCancelQingYuanSuccess")
SCancelQingYuanSuccess.TYPEID = 12602886
function SCancelQingYuanSuccess:ctor(team_leader_role_id, team_leader_role_name)
  self.id = 12602886
  self.team_leader_role_id = team_leader_role_id or nil
  self.team_leader_role_name = team_leader_role_name or nil
end
function SCancelQingYuanSuccess:marshal(os)
  os:marshalInt64(self.team_leader_role_id)
  os:marshalString(self.team_leader_role_name)
end
function SCancelQingYuanSuccess:unmarshal(os)
  self.team_leader_role_id = os:unmarshalInt64()
  self.team_leader_role_name = os:unmarshalString()
end
function SCancelQingYuanSuccess:sizepolicy(size)
  return size <= 65535
end
return SCancelQingYuanSuccess
