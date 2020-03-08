local SVotingStatusRes = class("SVotingStatusRes")
SVotingStatusRes.TYPEID = 12602117
function SVotingStatusRes:ctor(myVoteInfo, idx2VoteMoney)
  self.id = 12602117
  self.myVoteInfo = myVoteInfo or {}
  self.idx2VoteMoney = idx2VoteMoney or {}
end
function SVotingStatusRes:marshal(os)
  do
    local _size_ = 0
    for _, _ in pairs(self.myVoteInfo) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.myVoteInfo) do
      os:marshalInt32(k)
      os:marshalInt32(v)
    end
  end
  local _size_ = 0
  for _, _ in pairs(self.idx2VoteMoney) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.idx2VoteMoney) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SVotingStatusRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.myVoteInfo[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.idx2VoteMoney[k] = v
  end
end
function SVotingStatusRes:sizepolicy(size)
  return size <= 65535
end
return SVotingStatusRes
