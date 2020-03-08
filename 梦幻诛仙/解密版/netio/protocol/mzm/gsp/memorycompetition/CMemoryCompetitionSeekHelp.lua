local CMemoryCompetitionSeekHelp = class("CMemoryCompetitionSeekHelp")
CMemoryCompetitionSeekHelp.TYPEID = 12613128
function CMemoryCompetitionSeekHelp:ctor()
  self.id = 12613128
end
function CMemoryCompetitionSeekHelp:marshal(os)
end
function CMemoryCompetitionSeekHelp:unmarshal(os)
end
function CMemoryCompetitionSeekHelp:sizepolicy(size)
  return size <= 65535
end
return CMemoryCompetitionSeekHelp
