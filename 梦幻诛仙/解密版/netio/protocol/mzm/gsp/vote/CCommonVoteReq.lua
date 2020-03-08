local CCommonVoteReq = class("CCommonVoteReq")
CCommonVoteReq.TYPEID = 12611844
function CCommonVoteReq:ctor(activityId, voteIds)
  self.id = 12611844
  self.activityId = activityId or nil
  self.voteIds = voteIds or {}
end
function CCommonVoteReq:marshal(os)
  os:marshalInt32(self.activityId)
  local _size_ = 0
  for _, _ in pairs(self.voteIds) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, _ in pairs(self.voteIds) do
    os:marshalInt32(k)
  end
end
function CCommonVoteReq:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    self.voteIds[v] = v
  end
end
function CCommonVoteReq:sizepolicy(size)
  return size <= 65535
end
return CCommonVoteReq
