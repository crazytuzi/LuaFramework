local SMakeQingYuanRelationSuccess = class("SMakeQingYuanRelationSuccess")
SMakeQingYuanRelationSuccess.TYPEID = 12602885
function SMakeQingYuanRelationSuccess:ctor(team_leader_role_id, team_member_role_id, sessionid)
  self.id = 12602885
  self.team_leader_role_id = team_leader_role_id or nil
  self.team_member_role_id = team_member_role_id or nil
  self.sessionid = sessionid or nil
end
function SMakeQingYuanRelationSuccess:marshal(os)
  os:marshalInt64(self.team_leader_role_id)
  os:marshalInt64(self.team_member_role_id)
  os:marshalInt64(self.sessionid)
end
function SMakeQingYuanRelationSuccess:unmarshal(os)
  self.team_leader_role_id = os:unmarshalInt64()
  self.team_member_role_id = os:unmarshalInt64()
  self.sessionid = os:unmarshalInt64()
end
function SMakeQingYuanRelationSuccess:sizepolicy(size)
  return size <= 65535
end
return SMakeQingYuanRelationSuccess
