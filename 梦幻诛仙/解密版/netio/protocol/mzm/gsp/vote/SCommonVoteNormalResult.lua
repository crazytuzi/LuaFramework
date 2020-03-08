local SCommonVoteNormalResult = class("SCommonVoteNormalResult")
SCommonVoteNormalResult.TYPEID = 12611843
SCommonVoteNormalResult.VOTE_ERR__COUNT_EXHAUSTED = 1
function SCommonVoteNormalResult:ctor(result, args)
  self.id = 12611843
  self.result = result or nil
  self.args = args or {}
end
function SCommonVoteNormalResult:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SCommonVoteNormalResult:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SCommonVoteNormalResult:sizepolicy(size)
  return size <= 65535
end
return SCommonVoteNormalResult
