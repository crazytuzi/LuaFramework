local SMemoryCompetitionHelpAnswerNotfiy = class("SMemoryCompetitionHelpAnswerNotfiy")
SMemoryCompetitionHelpAnswerNotfiy.TYPEID = 12613132
function SMemoryCompetitionHelpAnswerNotfiy:ctor(activity_cfg_id, active_help_role_id, answer_id)
  self.id = 12613132
  self.activity_cfg_id = activity_cfg_id or nil
  self.active_help_role_id = active_help_role_id or nil
  self.answer_id = answer_id or nil
end
function SMemoryCompetitionHelpAnswerNotfiy:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt64(self.active_help_role_id)
  os:marshalInt32(self.answer_id)
end
function SMemoryCompetitionHelpAnswerNotfiy:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.active_help_role_id = os:unmarshalInt64()
  self.answer_id = os:unmarshalInt32()
end
function SMemoryCompetitionHelpAnswerNotfiy:sizepolicy(size)
  return size <= 65535
end
return SMemoryCompetitionHelpAnswerNotfiy
