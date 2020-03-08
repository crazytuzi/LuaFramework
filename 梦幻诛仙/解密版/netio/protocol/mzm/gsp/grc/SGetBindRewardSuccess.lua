local SGetBindRewardSuccess = class("SGetBindRewardSuccess")
SGetBindRewardSuccess.TYPEID = 12600376
function SGetBindRewardSuccess:ctor(open_id, reward_time, bind_type)
  self.id = 12600376
  self.open_id = open_id or nil
  self.reward_time = reward_time or nil
  self.bind_type = bind_type or nil
end
function SGetBindRewardSuccess:marshal(os)
  os:marshalOctets(self.open_id)
  os:marshalInt32(self.reward_time)
  os:marshalInt32(self.bind_type)
end
function SGetBindRewardSuccess:unmarshal(os)
  self.open_id = os:unmarshalOctets()
  self.reward_time = os:unmarshalInt32()
  self.bind_type = os:unmarshalInt32()
end
function SGetBindRewardSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetBindRewardSuccess
