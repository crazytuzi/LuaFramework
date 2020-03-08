local OctetsStream = require("netio.OctetsStream")
local AchievementConst = class("AchievementConst")
AchievementConst.MAIL_AWARD_STATE = 1
AchievementConst.NOT_MAIL_AWARD_STATE = 0
AchievementConst.YES_MAIL_AWARD_STATE = 1
AchievementConst.ACTIVITY_JOIN_TIME = 1
AchievementConst.DONE_LEVEL_EVENT_ID = 1
function AchievementConst:ctor()
end
function AchievementConst:marshal(os)
end
function AchievementConst:unmarshal(os)
end
return AchievementConst
