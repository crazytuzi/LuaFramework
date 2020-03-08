local SRecallFriendFailed = class("SRecallFriendFailed")
SRecallFriendFailed.TYPEID = 12600368
SRecallFriendFailed.ERROR_RECALL_SWITCH_NOT_OPEN = -1
SRecallFriendFailed.ERROR_RECALL_REPEAT_IN_ONE_PERIOD = -2
SRecallFriendFailed.ERROR_RECALL_REDIS_LOCK_FAILED = -3
SRecallFriendFailed.ERROR_RECALL_TODAY_FILED = -4
SRecallFriendFailed.ERROR_RECALL_FRIEND_FILLED = -5
SRecallFriendFailed.ERROR_RECALL_LOGIN_TIME_FIELD = -6
SRecallFriendFailed.ERROR_RECALL_LOGIN_TIME = -7
SRecallFriendFailed.ERROR_RECALL_MAX_LEVEL_FIELD = -8
SRecallFriendFailed.ERROR_RECALL_MAX_LEVEL = -9
SRecallFriendFailed.ERROR_RECALL_NET = -10
SRecallFriendFailed.ERROR_RECALL_FRIEND_AWARD_FAIL = -11
SRecallFriendFailed.ERROR_RECALL_NOT_FRIEND = -12
function SRecallFriendFailed:ctor(zone_id, role_id, open_id, retcode)
  self.id = 12600368
  self.zone_id = zone_id or nil
  self.role_id = role_id or nil
  self.open_id = open_id or nil
  self.retcode = retcode or nil
end
function SRecallFriendFailed:marshal(os)
  os:marshalInt32(self.zone_id)
  os:marshalInt64(self.role_id)
  os:marshalOctets(self.open_id)
  os:marshalInt32(self.retcode)
end
function SRecallFriendFailed:unmarshal(os)
  self.zone_id = os:unmarshalInt32()
  self.role_id = os:unmarshalInt64()
  self.open_id = os:unmarshalOctets()
  self.retcode = os:unmarshalInt32()
end
function SRecallFriendFailed:sizepolicy(size)
  return size <= 65535
end
return SRecallFriendFailed
