local SSynCommonVoteInfo = class("SSynCommonVoteInfo")
SSynCommonVoteInfo.TYPEID = 12611841
function SSynCommonVoteInfo:ctor(activityId2VoteData)
  self.id = 12611841
  self.activityId2VoteData = activityId2VoteData or {}
end
function SSynCommonVoteInfo:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.activityId2VoteData) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.activityId2VoteData) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function SSynCommonVoteInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.vote.VoteDatas")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.activityId2VoteData[k] = v
  end
end
function SSynCommonVoteInfo:sizepolicy(size)
  return size <= 65535
end
return SSynCommonVoteInfo
