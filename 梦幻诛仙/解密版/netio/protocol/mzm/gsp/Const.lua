local OctetsStream = require("netio.OctetsStream")
local Const = class("Const")
Const.ERR_GM_KICKOUT = 2049
Const.ERR_MAX_ACCOUNT_KICKOUT = 2050
Const.ERR_MAX_LOAD_NUM_KICKOUT = 2051
Const.AQIDIP_UPDATE_CASH = 2052
Const.ERR_SERVER_SHUTDOWN = 2053
Const.ERR_LONG_IN_MAXTIME = 2054
Const.ERR_FORCE_KICKOUT = 2055
Const.ERR_CROSS_SERVER_FORCE_KICKOUT = 2056
Const.ERR_RETURN_ORIGINAL_SERVER_FORCE_KICKOUT = 2057
Const.ERR_ADDICTION = 2058
Const.ERR_FORCE_RECONNECT = 2059
Const.ERR_BAN_LOGIN = 8013
function Const:ctor()
end
function Const:marshal(os)
end
function Const:unmarshal(os)
end
return Const
