local SRecallFriendNormalFail = class("SRecallFriendNormalFail")
SRecallFriendNormalFail.TYPEID = 12600361
SRecallFriendNormalFail.ERROR_NOT_RECALL_BACK = 1
SRecallFriendNormalFail.ERROR_BIG_GIFT_ALEARDY_AWARDED = 2
SRecallFriendNormalFail.ERROR_BIG_GIFT_AWARDED_FAILED = 3
SRecallFriendNormalFail.ERROR_RECALL_NUM_NOT_ENOUGH = 4
SRecallFriendNormalFail.ERROR_RECALL_NUM_TOO_MANEY_AWARD_NOT_EXIST = 5
SRecallFriendNormalFail.ERROR_RECALL_NUM_NOT_CONTINUATION = 6
SRecallFriendNormalFail.ERROR_RECALL_NUM_AWARD_FAIL = 7
SRecallFriendNormalFail.ERROR_RECALL_SIGN_EXPIRED = 8
SRecallFriendNormalFail.ERROR_RECALL_USER_NOT_EXIST = 9
SRecallFriendNormalFail.ERROR_RECALL_OPEN_ID_NOT_MATCH = 10
SRecallFriendNormalFail.ERROR_RECALL_TIMES_NOT_ENOUGH = 11
SRecallFriendNormalFail.ERROR_BE_RECALL_TOO_MANY = 12
SRecallFriendNormalFail.ERROR_RECALL_SIGN_ALEARDY = 13
SRecallFriendNormalFail.ERROR_RECALL_SIGN_DAY_NOT_EXIST = 14
SRecallFriendNormalFail.ERROR_RECALL_SIGN_DAY_AWARDED_FAILED = 15
SRecallFriendNormalFail.ERROR_RECALL_SIGN_DAY_NOT_TODAY = 16
SRecallFriendNormalFail.ERROR_RECALL_REPEAT_IN_ONE_PERIOD = 17
SRecallFriendNormalFail.ERROR_RECALL_REPEAT_NOT_IN_SAME_ZONE = 18
SRecallFriendNormalFail.ERROR_RECALL_FRIEND_AWARD_FAIL = 19
SRecallFriendNormalFail.ERROR_RECALL_FRIEND_CAN_NOT = 20
SRecallFriendNormalFail.ERROR_RECALL_FRIEND_SWITCH_NOT_OPEN = 21
SRecallFriendNormalFail.ERROR_RECALL_REDIS_LOCK_FAILED = 22
SRecallFriendNormalFail.ERROR_RECALL_TODAY_FILED = 23
SRecallFriendNormalFail.ERROR_RECALL_FRIEND_FILLED = 24
SRecallFriendNormalFail.ERROR_RECALL_LOGIN_TIME_FIELD = 25
SRecallFriendNormalFail.ERROR_RECALL_LOGIN_TIME = 26
SRecallFriendNormalFail.ERROR_RECALL_MAX_LEVEL_FIELD = 27
SRecallFriendNormalFail.ERROR_RECALL_MAX_LEVEL = 28
function SRecallFriendNormalFail:ctor(result)
  self.id = 12600361
  self.result = result or nil
end
function SRecallFriendNormalFail:marshal(os)
  os:marshalInt32(self.result)
end
function SRecallFriendNormalFail:unmarshal(os)
  self.result = os:unmarshalInt32()
end
function SRecallFriendNormalFail:sizepolicy(size)
  return size <= 65535
end
return SRecallFriendNormalFail
