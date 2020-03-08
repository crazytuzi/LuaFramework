local OctetsStream = require("netio.OctetsStream")
local WatchmoonErrorCode = class("WatchmoonErrorCode")
WatchmoonErrorCode.WATCH_MOON_COUNT_ERROR = 1
WatchmoonErrorCode.GANG_ERROR = 3
WatchmoonErrorCode.ROLE_OFF = 4
WatchmoonErrorCode.ROLE_IN_WATCH_MOON = 5
WatchmoonErrorCode.ROLE_IN_XUNLUO = 6
WatchmoonErrorCode.ROLE_STATE_ERROR = 7
function WatchmoonErrorCode:ctor()
end
function WatchmoonErrorCode:marshal(os)
end
function WatchmoonErrorCode:unmarshal(os)
end
return WatchmoonErrorCode
