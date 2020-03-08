local CMemoryCompetitionHelpAnswer = class("CMemoryCompetitionHelpAnswer")
CMemoryCompetitionHelpAnswer.TYPEID = 12613124
function CMemoryCompetitionHelpAnswer:ctor(seek_help_role_id, answer_id)
  self.id = 12613124
  self.seek_help_role_id = seek_help_role_id or nil
  self.answer_id = answer_id or nil
end
function CMemoryCompetitionHelpAnswer:marshal(os)
  os:marshalInt64(self.seek_help_role_id)
  os:marshalInt32(self.answer_id)
end
function CMemoryCompetitionHelpAnswer:unmarshal(os)
  self.seek_help_role_id = os:unmarshalInt64()
  self.answer_id = os:unmarshalInt32()
end
function CMemoryCompetitionHelpAnswer:sizepolicy(size)
  return size <= 65535
end
return CMemoryCompetitionHelpAnswer
