local OctetsStream = require("netio.OctetsStream")
local MenPaiStarRet = class("MenPaiStarRet")
MenPaiStarRet.ERROR_SYSTEM = 1
MenPaiStarRet.ERROR_USERID = 2
MenPaiStarRet.ERROR_CFG = 3
MenPaiStarRet.ERROR_YUANBAO_INCONSISTENT = 4
MenPaiStarRet.ERROR_NPC_SERVICE = 5
MenPaiStarRet.ERROR_CAMPAIGN = 6
MenPaiStarRet.ERROR_VOTE = 7
MenPaiStarRet.ERROR_ROLE_IS_NOT_CAMPAIGN = 8
MenPaiStarRet.ERROR_ROLE_IS_NOT_VOTE = 9
MenPaiStarRet.ERROR_ROLE_NOT_IN_GANG = 10
MenPaiStarRet.ERROR_GANG_INCONSISTENT = 11
MenPaiStarRet.ERROR_GANG_CHAT = 12
MenPaiStarRet.ERROR_CAMPAIGN_FIGHT_TIME_OUT = 13
MenPaiStarRet.ERROR_VOTE_FIGHT_TIME_OUT = 14
MenPaiStarRet.ERROR_VOTE_TIME_OUT = 15
MenPaiStarRet.ERROR_CANVASS_TIME_OUT = 16
MenPaiStarRet.ERROR_CAN_NOT_JOIN_ACTIVITY = 17
MenPaiStarRet.ERROR_ACTIVITY_IN_AWARD = 18
MenPaiStarRet.ERROR_NOT_IN_CAMPAIGN_RANK = 19
function MenPaiStarRet:ctor()
end
function MenPaiStarRet:marshal(os)
end
function MenPaiStarRet:unmarshal(os)
end
return MenPaiStarRet
