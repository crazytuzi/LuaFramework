local OctetsStream = require("netio.OctetsStream")
local CoupleDailyConst = class("CoupleDailyConst")
CoupleDailyConst.REFUSE = 0
CoupleDailyConst.AGREE = 1
CoupleDailyConst.A_SELECTOR = 0
CoupleDailyConst.B_SELECTOR = 1
CoupleDailyConst.NOT_MATCH = 0
CoupleDailyConst.YES_MATCH = 1
CoupleDailyConst.NOT_AWARD = 0
CoupleDailyConst.YES_AWARD = 1
function CoupleDailyConst:ctor()
end
function CoupleDailyConst:marshal(os)
end
function CoupleDailyConst:unmarshal(os)
end
return CoupleDailyConst
