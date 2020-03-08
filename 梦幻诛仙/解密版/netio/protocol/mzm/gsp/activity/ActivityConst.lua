local OctetsStream = require("netio.OctetsStream")
local ActivityConst = class("ActivityConst")
ActivityConst.OPEN_STATE_NORMAL = 0
ActivityConst.OPEN_STATE_PAUSE = 1
ActivityConst.OPEN_STATE_FORCE_OPEN = 2
ActivityConst.OPEN_STATE_FORCE_CLOSE = 4
function ActivityConst:ctor()
end
function ActivityConst:marshal(os)
end
function ActivityConst:unmarshal(os)
end
return ActivityConst
