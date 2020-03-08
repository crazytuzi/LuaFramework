local SSyncFetchedRewards = class("SSyncFetchedRewards")
SSyncFetchedRewards.TYPEID = 12615689
function SSyncFetchedRewards:ctor(fetched_rewards, activity_id)
  self.id = 12615689
  self.fetched_rewards = fetched_rewards or {}
  self.activity_id = activity_id or nil
end
function SSyncFetchedRewards:marshal(os)
  do
    local _size_ = 0
    for _, _ in pairs(self.fetched_rewards) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, _ in pairs(self.fetched_rewards) do
      os:marshalInt32(k)
    end
  end
  os:marshalInt32(self.activity_id)
end
function SSyncFetchedRewards:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    self.fetched_rewards[v] = v
  end
  self.activity_id = os:unmarshalInt32()
end
function SSyncFetchedRewards:sizepolicy(size)
  return size <= 65535
end
return SSyncFetchedRewards
