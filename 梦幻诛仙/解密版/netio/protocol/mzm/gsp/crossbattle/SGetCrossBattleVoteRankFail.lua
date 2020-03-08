local SGetCrossBattleVoteRankFail = class("SGetCrossBattleVoteRankFail")
SGetCrossBattleVoteRankFail.TYPEID = 12616964
SGetCrossBattleVoteRankFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SGetCrossBattleVoteRankFail.ROLE_STATUS_ERROR = -2
SGetCrossBattleVoteRankFail.PARAM_ERROR = -3
SGetCrossBattleVoteRankFail.CHECK_NPC_SERVICE_ERROR = -4
function SGetCrossBattleVoteRankFail:ctor(res)
  self.id = 12616964
  self.res = res or nil
end
function SGetCrossBattleVoteRankFail:marshal(os)
  os:marshalInt32(self.res)
end
function SGetCrossBattleVoteRankFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SGetCrossBattleVoteRankFail:sizepolicy(size)
  return size <= 65535
end
return SGetCrossBattleVoteRankFail
