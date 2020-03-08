local CMemoryCompetitionAnswer = class("CMemoryCompetitionAnswer")
CMemoryCompetitionAnswer.TYPEID = 12613123
function CMemoryCompetitionAnswer:ctor(answer)
  self.id = 12613123
  self.answer = answer or nil
end
function CMemoryCompetitionAnswer:marshal(os)
  os:marshalInt32(self.answer)
end
function CMemoryCompetitionAnswer:unmarshal(os)
  self.answer = os:unmarshalInt32()
end
function CMemoryCompetitionAnswer:sizepolicy(size)
  return size <= 65535
end
return CMemoryCompetitionAnswer
