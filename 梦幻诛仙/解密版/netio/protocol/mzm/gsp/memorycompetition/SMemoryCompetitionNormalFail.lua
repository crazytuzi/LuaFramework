local SMemoryCompetitionNormalFail = class("SMemoryCompetitionNormalFail")
SMemoryCompetitionNormalFail.TYPEID = 12613122
SMemoryCompetitionNormalFail.NOT_IN_GAME = 1
SMemoryCompetitionNormalFail.GAME_UNIQUE_ID_NOT_EXIST = 2
SMemoryCompetitionNormalFail.THE_QUESTION_ALEARDY_OVER = 3
SMemoryCompetitionNormalFail.ALEARDY_SEEK_HELP = 4
SMemoryCompetitionNormalFail.ALEARDY_ANSWER = 5
SMemoryCompetitionNormalFail.SEEK_HELP_TIMES_NOT_ENOUGH = 6
SMemoryCompetitionNormalFail.SEEK_HELP_ROIE_ID_NOT_IN_GAME = 7
SMemoryCompetitionNormalFail.SEEK_HELP_ROIL_NOT_SEEK_HELP = 8
SMemoryCompetitionNormalFail.ALEARDY_BE_HELPED = 9
SMemoryCompetitionNormalFail.QUESTION_ALEARDY_ANSERED = 10
SMemoryCompetitionNormalFail.MEMORY_CFG_NOT_EXIST = 11
SMemoryCompetitionNormalFail.NOT_SEEK_HELP = 12
SMemoryCompetitionNormalFail.NOT_FOUND_QUESTION_INFO = 13
SMemoryCompetitionNormalFail.TIME_OUT = 14
SMemoryCompetitionNormalFail.MAPPING_CFG_NOT_EXIST = 15
SMemoryCompetitionNormalFail.RANDOM_QUESTION_ERROR = 16
function SMemoryCompetitionNormalFail:ctor(result)
  self.id = 12613122
  self.result = result or nil
end
function SMemoryCompetitionNormalFail:marshal(os)
  os:marshalInt32(self.result)
end
function SMemoryCompetitionNormalFail:unmarshal(os)
  self.result = os:unmarshalInt32()
end
function SMemoryCompetitionNormalFail:sizepolicy(size)
  return size <= 65535
end
return SMemoryCompetitionNormalFail
