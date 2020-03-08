local OctetsStream = require("netio.OctetsStream")
local LuckyBagRet = class("LuckyBagRet")
LuckyBagRet.ERROR_SYSTEM = 1
LuckyBagRet.ERROR_AWARD = 2
LuckyBagRet.ERROR_LAST_AWARD_NOT_FINISH = 3
LuckyBagRet.ERROR_CFG = 4
LuckyBagRet.ERROR_PARAM_INVALID = 5
function LuckyBagRet:ctor()
end
function LuckyBagRet:marshal(os)
end
function LuckyBagRet:unmarshal(os)
end
return LuckyBagRet
