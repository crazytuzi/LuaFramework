local SMemoryCompetitionAnswerNotify = class("SMemoryCompetitionAnswerNotify")
SMemoryCompetitionAnswerNotify.TYPEID = 12613133
function SMemoryCompetitionAnswerNotify:ctor(activity_cfg_id, team_member_role_id, answer_id)
  self.id = 12613133
  self.activity_cfg_id = activity_cfg_id or nil
  self.team_member_role_id = team_member_role_id or nil
  self.answer_id = answer_id or nil
end
function SMemoryCompetitionAnswerNotify:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt64(self.team_member_role_id)
  os:marshalInt32(self.answer_id)
end
function SMemoryCompetitionAnswerNotify:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.team_member_role_id = os:unmarshalInt64()
  self.answer_id = os:unmarshalInt32()
end
function SMemoryCompetitionAnswerNotify:sizepolicy(size)
  return size <= 65535
end
return SMemoryCompetitionAnswerNotify
