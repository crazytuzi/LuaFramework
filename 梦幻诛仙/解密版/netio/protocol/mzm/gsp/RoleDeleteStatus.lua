local OctetsStream = require("netio.OctetsStream")
local RoleDeleteStatus = class("RoleDeleteStatus")
RoleDeleteStatus.STATE_DELETE_COUNTER = 0
RoleDeleteStatus.STATE_DELETE = 1
RoleDeleteStatus.STATE_REAL_DELETE = 2
RoleDeleteStatus.STATE_NORMAL = 3
RoleDeleteStatus.STATE_RECOVERY = 4
function RoleDeleteStatus:ctor()
end
function RoleDeleteStatus:marshal(os)
end
function RoleDeleteStatus:unmarshal(os)
end
return RoleDeleteStatus
