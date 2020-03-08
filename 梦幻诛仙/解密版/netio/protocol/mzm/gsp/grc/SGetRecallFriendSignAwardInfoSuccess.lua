local SGetRecallFriendSignAwardInfoSuccess = class("SGetRecallFriendSignAwardInfoSuccess")
SGetRecallFriendSignAwardInfoSuccess.TYPEID = 12600357
function SGetRecallFriendSignAwardInfoSuccess:ctor(sign_award_state_map)
  self.id = 12600357
  self.sign_award_state_map = sign_award_state_map or {}
end
function SGetRecallFriendSignAwardInfoSuccess:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.sign_award_state_map) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.sign_award_state_map) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SGetRecallFriendSignAwardInfoSuccess:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.sign_award_state_map[k] = v
  end
end
function SGetRecallFriendSignAwardInfoSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetRecallFriendSignAwardInfoSuccess
