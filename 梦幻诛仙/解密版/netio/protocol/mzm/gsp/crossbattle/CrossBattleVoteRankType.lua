local OctetsStream = require("netio.OctetsStream")
local CrossBattleVoteRankType = class("CrossBattleVoteRankType")
CrossBattleVoteRankType.TYPE_VOTE_NUM = 0
CrossBattleVoteRankType.TYPE_AVERAGE_FIGHT_VALUE = 1
function CrossBattleVoteRankType:ctor()
end
function CrossBattleVoteRankType:marshal(os)
end
function CrossBattleVoteRankType:unmarshal(os)
end
return CrossBattleVoteRankType
