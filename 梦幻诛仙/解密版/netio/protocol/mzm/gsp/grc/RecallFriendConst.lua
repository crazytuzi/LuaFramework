local OctetsStream = require("netio.OctetsStream")
local RecallFriendConst = class("RecallFriendConst")
RecallFriendConst.SIGN_AWARD_CAN_AWARD = 0
RecallFriendConst.SIGN_AWARD_EXPIRED = 1
RecallFriendConst.SIGN_AWARD_CAN_NOT_AWARD = 2
RecallFriendConst.SIGN_AWARD_ALEARDY_AWARD = 3
RecallFriendConst.NO_BIG_GIFT_AWARD = 0
RecallFriendConst.YES_BIG_GIFT_AWARD = 1
function RecallFriendConst:ctor()
end
function RecallFriendConst:marshal(os)
end
function RecallFriendConst:unmarshal(os)
end
return RecallFriendConst
