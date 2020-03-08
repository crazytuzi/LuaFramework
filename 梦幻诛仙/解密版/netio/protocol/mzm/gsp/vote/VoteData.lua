local OctetsStream = require("netio.OctetsStream")
local VoteData = class("VoteData")
function VoteData:ctor(votedIds)
  self.votedIds = votedIds or {}
end
function VoteData:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.votedIds) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, _ in pairs(self.votedIds) do
    os:marshalInt32(k)
  end
end
function VoteData:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    self.votedIds[v] = v
  end
end
return VoteData
