local OctetsStream = require("netio.OctetsStream")
local GeniusRet = class("GeniusRet")
GeniusRet.ERROR_SYSTEM = 1
GeniusRet.ERROR_USERID = 2
GeniusRet.ERROR_CFG = 3
GeniusRet.ERROR_LEVEL = 4
GeniusRet.ERROR_GENIUS_EMPTY = 5
GeniusRet.ERROR_SWITCH_GENIUS_SERIES = 6
GeniusRet.ERROR_GENIU_PLAN_PARAM_INVALID = 7
GeniusRet.ERROR_GENIU_POINT_OVER_FLOW = 8
GeniusRet.ERROR_PREVIOUS_GENIUS_POINT_NOT_ENOUGH = 9
GeniusRet.ERROR_PREVIOUS_POINT_NOT_ENOUGH = 10
GeniusRet.ERROR_GENIUS_IGNORE = 11
function GeniusRet:ctor()
end
function GeniusRet:marshal(os)
end
function GeniusRet:unmarshal(os)
end
return GeniusRet
