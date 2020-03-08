local OctetsStream = require("netio.OctetsStream")
local PopupType = class("PopupType")
PopupType.ONLINE_TIME = 1
PopupType.DAILY_TOTAL_ONLINE_TIME = 2
function PopupType:ctor()
end
function PopupType:marshal(os)
end
function PopupType:unmarshal(os)
end
return PopupType
