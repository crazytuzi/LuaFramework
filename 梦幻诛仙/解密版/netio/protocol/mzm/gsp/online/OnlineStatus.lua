local OctetsStream = require("netio.OctetsStream")
local OnlineStatus = class("OnlineStatus")
OnlineStatus.ST_LOGIN = 2
OnlineStatus.ST_ENTERWORLD = 3
OnlineStatus.ST_PREPARE_OFFLINE = 4
OnlineStatus.ST_PROTECT = 8
OnlineStatus.ST_LOGIN_PROTECT = 10
OnlineStatus.ST_ERROR = -1
function OnlineStatus:ctor()
end
function OnlineStatus:marshal(os)
end
function OnlineStatus:unmarshal(os)
end
return OnlineStatus
