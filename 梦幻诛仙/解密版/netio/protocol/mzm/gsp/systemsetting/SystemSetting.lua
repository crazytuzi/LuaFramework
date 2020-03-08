local OctetsStream = require("netio.OctetsStream")
local SystemSetting = class("SystemSetting")
SystemSetting.STATE_NOT_SETTING = 0
SystemSetting.STATE_SETTING = 1
SystemSetting.VALID_FRIEND = 2
SystemSetting.QUERY_EQUIPINFO = 3
SystemSetting.VALIDATE_ADD_FRIEND_LV = 4
SystemSetting.FORBID_STRANGER_TEAM_INVITE = 5
SystemSetting.ADD_FRIEND_REQUIRED_LV = 6
function SystemSetting:ctor()
end
function SystemSetting:marshal(os)
end
function SystemSetting:unmarshal(os)
end
return SystemSetting
