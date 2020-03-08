local SGetBindRewardFailed = class("SGetBindRewardFailed")
SGetBindRewardFailed.TYPEID = 12600379
SGetBindRewardFailed.ERROR_RECALL_VITALITY_EXPIRE = -1
SGetBindRewardFailed.ERROR_RECALL_BIND_REWARD = -2
SGetBindRewardFailed.ERROR_RECALL_VITALITY_NOT_ENOUGH = -3
SGetBindRewardFailed.ERROR_RECALL_FRIEND_VITALITY_NOT_ENOUGH = -4
SGetBindRewardFailed.ERROR_RECALL_VITALITY_TIME = -5
SGetBindRewardFailed.ERROR_RECALL_NOT_BIND = -6
SGetBindRewardFailed.ERROR_RECALL_NET = -7
function SGetBindRewardFailed:ctor(open_id, bind_type, retcode)
  self.id = 12600379
  self.open_id = open_id or nil
  self.bind_type = bind_type or nil
  self.retcode = retcode or nil
end
function SGetBindRewardFailed:marshal(os)
  os:marshalOctets(self.open_id)
  os:marshalInt32(self.bind_type)
  os:marshalInt32(self.retcode)
end
function SGetBindRewardFailed:unmarshal(os)
  self.open_id = os:unmarshalOctets()
  self.bind_type = os:unmarshalInt32()
  self.retcode = os:unmarshalInt32()
end
function SGetBindRewardFailed:sizepolicy(size)
  return size <= 65535
end
return SGetBindRewardFailed
