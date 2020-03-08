local SAgreeOrRefuseQingYuan = class("SAgreeOrRefuseQingYuan")
SAgreeOrRefuseQingYuan.TYPEID = 12602883
function SAgreeOrRefuseQingYuan:ctor(operator, team_leader_role_id, team_member_role_id)
  self.id = 12602883
  self.operator = operator or nil
  self.team_leader_role_id = team_leader_role_id or nil
  self.team_member_role_id = team_member_role_id or nil
end
function SAgreeOrRefuseQingYuan:marshal(os)
  os:marshalInt32(self.operator)
  os:marshalInt64(self.team_leader_role_id)
  os:marshalInt64(self.team_member_role_id)
end
function SAgreeOrRefuseQingYuan:unmarshal(os)
  self.operator = os:unmarshalInt32()
  self.team_leader_role_id = os:unmarshalInt64()
  self.team_member_role_id = os:unmarshalInt64()
end
function SAgreeOrRefuseQingYuan:sizepolicy(size)
  return size <= 65535
end
return SAgreeOrRefuseQingYuan
