local SRoleLadderInfoRes = class("SRoleLadderInfoRes")
SRoleLadderInfoRes.TYPEID = 12607264
function SRoleLadderInfoRes:ctor(stage, matchScore, winCount, loseCount, stageAwards)
  self.id = 12607264
  self.stage = stage or nil
  self.matchScore = matchScore or nil
  self.winCount = winCount or nil
  self.loseCount = loseCount or nil
  self.stageAwards = stageAwards or {}
end
function SRoleLadderInfoRes:marshal(os)
  os:marshalInt32(self.stage)
  os:marshalInt32(self.matchScore)
  os:marshalInt32(self.winCount)
  os:marshalInt32(self.loseCount)
  local _size_ = 0
  for _, _ in pairs(self.stageAwards) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, _ in pairs(self.stageAwards) do
    os:marshalInt32(k)
  end
end
function SRoleLadderInfoRes:unmarshal(os)
  self.stage = os:unmarshalInt32()
  self.matchScore = os:unmarshalInt32()
  self.winCount = os:unmarshalInt32()
  self.loseCount = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    self.stageAwards[v] = v
  end
end
function SRoleLadderInfoRes:sizepolicy(size)
  return size <= 65535
end
return SRoleLadderInfoRes
