local OctetsStream = require("netio.OctetsStream")
local RaceConsts = class("RaceConsts")
RaceConsts.RACE_NORMAL_STAGE = -1
RaceConsts.RACE_VOTE_STAGE = 0
RaceConsts.RACE_VOTE_SUCCESS = 1
RaceConsts.RACE_RUN_STAGE = 2
function RaceConsts:ctor()
end
function RaceConsts:marshal(os)
end
function RaceConsts:unmarshal(os)
end
return RaceConsts
