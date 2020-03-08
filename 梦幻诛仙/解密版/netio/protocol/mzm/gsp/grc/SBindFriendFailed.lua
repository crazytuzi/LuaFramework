local SBindFriendFailed = class("SBindFriendFailed")
SBindFriendFailed.TYPEID = 12600373
SBindFriendFailed.ERROR_RECALL_NOT_LOSS = -1
SBindFriendFailed.ERROR_RECALL_BIND_EXPIRED = -2
SBindFriendFailed.ERROR_RECALL_BINDED = -3
SBindFriendFailed.ERROR_RECALL_BIND_FULL = -4
SBindFriendFailed.ERROR_RECALL_REDIS_LOCK_FAILED = -5
SBindFriendFailed.ERROR_RECALL_FRIEND_BIND_FULL = -6
SBindFriendFailed.ERROR_RECALL_NET = -7
SBindFriendFailed.ERROR_RECALL_NOT_FRIEND = -8
SBindFriendFailed.ERROR_RECALL_BIND_TOGETHER_FILLED = -9
function SBindFriendFailed:ctor(open_id, retcode)
  self.id = 12600373
  self.open_id = open_id or nil
  self.retcode = retcode or nil
end
function SBindFriendFailed:marshal(os)
  os:marshalOctets(self.open_id)
  os:marshalInt32(self.retcode)
end
function SBindFriendFailed:unmarshal(os)
  self.open_id = os:unmarshalOctets()
  self.retcode = os:unmarshalInt32()
end
function SBindFriendFailed:sizepolicy(size)
  return size <= 65535
end
return SBindFriendFailed
