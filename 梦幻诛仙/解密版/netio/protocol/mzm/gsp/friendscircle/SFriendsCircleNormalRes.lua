local SFriendsCircleNormalRes = class("SFriendsCircleNormalRes")
SFriendsCircleNormalRes.TYPEID = 12625423
SFriendsCircleNormalRes.FRIENDS_CIRCLE_NOT_OPEN = 1
SFriendsCircleNormalRes.BUY_TREASURE_NOT_OPEN = 2
SFriendsCircleNormalRes.TREAD_NOT_OPEN = 3
SFriendsCircleNormalRes.GIVE_PRESENT_NOT_OPEN = 4
SFriendsCircleNormalRes.PLACE_TREASURE_BOX_NUM_LIMIT = 5
SFriendsCircleNormalRes.USER_ID_NULL = 6
SFriendsCircleNormalRes.CURRENCY_NOT_EQUAL_WITH_SERVER = 7
SFriendsCircleNormalRes.CURRENCY_NOT_ENOUGH = 8
SFriendsCircleNormalRes.CUT_CURRENCY_FAIL = 9
SFriendsCircleNormalRes.BUY_COUNT_NOT_VALID = 10
SFriendsCircleNormalRes.BUY_TREASURE_TOO_MANY = 11
SFriendsCircleNormalRes.ITEM_NOT_EXIST = 12
SFriendsCircleNormalRes.ITEM_NOT_FRIENDS_CIRCLE_ITEM = 13
SFriendsCircleNormalRes.ALEARDY_HAS_FRIENDS_CIRCLE_ITEM = 14
SFriendsCircleNormalRes.CUT_ITEM_ERROR = 15
SFriendsCircleNormalRes.REPLACE_ITEM_SAME_ERROR = 16
SFriendsCircleNormalRes.NOT_OWN_ITEM_ERROR = 17
SFriendsCircleNormalRes.ORNAMENT_ITEM_TYPE_ERROR = 18
SFriendsCircleNormalRes.BE_TROD_USER_ID_NOT_FOUND = 19
SFriendsCircleNormalRes.TREAD_USER_TIMES_LIMIT = 20
SFriendsCircleNormalRes.TREASURE_BOX_AWARD_FAIL = 21
SFriendsCircleNormalRes.REMOVE_GIFT_ITEM_FAIL = 22
SFriendsCircleNormalRes.ITEM_NOT_ENOUGH_AND_NOT_USE_YUANBAO = 23
SFriendsCircleNormalRes.ITEM_ENOUGH_AND_USE_YUANBAO = 24
SFriendsCircleNormalRes.ITEM_NOT_GIFT = 25
SFriendsCircleNormalRes.GIFT_NOT_GRADE = 26
SFriendsCircleNormalRes.ITEM_NOT_GRADE = 27
SFriendsCircleNormalRes.GIVE_CFG_NOT_EXIST = 28
SFriendsCircleNormalRes.ITEM_NOT_POPULARITY = 29
SFriendsCircleNormalRes.GIVE_GIFT_USER_ID_NOT_FOUND = 30
SFriendsCircleNormalRes.CROSS_SERVER_TREAD_RESULT_ERROR = 31
SFriendsCircleNormalRes.TREAD_SERIAL_NOU_FOUND = 32
SFriendsCircleNormalRes.TREAD_CONTEXT_NOT_MATCH = 33
SFriendsCircleNormalRes.ALEARDY_DEAL = 34
SFriendsCircleNormalRes.PLACE_TREASURE_BOX_RECORD_NOT_FOUND = 35
SFriendsCircleNormalRes.PLACE_TREASURE_BOX_CONTEXT_NOT_MATCH = 36
SFriendsCircleNormalRes.GIVE_GIFT_MESSAGE_TOO_LONG = 37
SFriendsCircleNormalRes.GIVE_GIFT_MESSAGE_SENSITIVE = 38
SFriendsCircleNormalRes.GIVE_ITEM_RECORD_NOT_FOUND = 39
SFriendsCircleNormalRes.GIVE_ITEM_CONTEXT_NOT_MATCH = 40
SFriendsCircleNormalRes.GIVE_ITEM_NUM_NOT_MATCH = 41
SFriendsCircleNormalRes.GIVE_ITEM_ERROR = 42
SFriendsCircleNormalRes.RANK_NUM_ERROR = 43
SFriendsCircleNormalRes.ROLE_LEVEL_FRIENDS_CIRCLE_ERROR = 44
SFriendsCircleNormalRes.ROLE_LEVEL_TREAD_ERROR = 45
SFriendsCircleNormalRes.ROLE_LEVEL_GIVE_GIFT_ERROR = 46
SFriendsCircleNormalRes.STATUS_ERROR = 47
SFriendsCircleNormalRes.SERIAL_CROSS_SERVER_STATUE_ERROR = 48
SFriendsCircleNormalRes.SSP_NOT_REPLY_ERROR = 49
SFriendsCircleNormalRes.ORNAMENT_NOT_OPEN = 50
SFriendsCircleNormalRes.WEEK_POPULARITY_HANDLE = 51
SFriendsCircleNormalRes.FRIENDS_CIRCLE_CHART_NOT_OPEN = 52
SFriendsCircleNormalRes.FRIENDS_CIRCLE_CROSS_SERVER_TREAD_NOT_OPEN = 53
SFriendsCircleNormalRes.FRIENDS_CIRCLE_CROSS_SERVER_GIFT_NOT_OPEN = 54
SFriendsCircleNormalRes.FRIENDS_CIRCLE_CROSS_SERVER_TREADING = 55
SFriendsCircleNormalRes.FRIENDS_CIRCLE_PARAMETER_ERROR = 56
SFriendsCircleNormalRes.FRIENDS_CIRCLE_BLACK_USER_ERROR = 57
SFriendsCircleNormalRes.FRIENDS_CIRCLE_BLACK_MAX_ERROR = 58
SFriendsCircleNormalRes.FRIENDS_CIRCLE_ALEARDY_BLACK_ERROR = 59
SFriendsCircleNormalRes.NOT_IN_BLACK_ERROR = 60
SFriendsCircleNormalRes.CROSS_SERVER_BLACK_NOT_OPEN_ERROR = 61
SFriendsCircleNormalRes.CROSS_SERVER_SERVER_ID_ERROR = 62
SFriendsCircleNormalRes.CROSS_SERVER_REPEAT_BLACK_ERROR = 63
SFriendsCircleNormalRes.ROLE_IN_BLACK_ERROR = 64
SFriendsCircleNormalRes.ROLE_BE_BLACKED_ERROR = 65
SFriendsCircleNormalRes.NET_ERROR = 66
SFriendsCircleNormalRes.CLIENT_NEED_YUAN_BAO_NOT_SAME = 67
SFriendsCircleNormalRes.TARGET_REPAIR_DATA_NOT_DO_TREAD = 68
SFriendsCircleNormalRes.TARGET_REPAIR_DATA_NOT_DO_GIFT = 69
function SFriendsCircleNormalRes:ctor(ret)
  self.id = 12625423
  self.ret = ret or nil
end
function SFriendsCircleNormalRes:marshal(os)
  os:marshalInt32(self.ret)
end
function SFriendsCircleNormalRes:unmarshal(os)
  self.ret = os:unmarshalInt32()
end
function SFriendsCircleNormalRes:sizepolicy(size)
  return size <= 65535
end
return SFriendsCircleNormalRes
