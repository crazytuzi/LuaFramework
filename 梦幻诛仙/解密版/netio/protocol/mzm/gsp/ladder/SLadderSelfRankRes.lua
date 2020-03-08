local SLadderSelfRankRes = class("SLadderSelfRankRes")
SLadderSelfRankRes.TYPEID = 12607274
function SLadderSelfRankRes:ctor(rankType, rank, stage, score)
  self.id = 12607274
  self.rankType = rankType or nil
  self.rank = rank or nil
  self.stage = stage or nil
  self.score = score or nil
end
function SLadderSelfRankRes:marshal(os)
  os:marshalInt32(self.rankType)
  os:marshalInt32(self.rank)
  os:marshalInt32(self.stage)
  os:marshalInt32(self.score)
end
function SLadderSelfRankRes:unmarshal(os)
  self.rankType = os:unmarshalInt32()
  self.rank = os:unmarshalInt32()
  self.stage = os:unmarshalInt32()
  self.score = os:unmarshalInt32()
end
function SLadderSelfRankRes:sizepolicy(size)
  return size <= 65535
end
return SLadderSelfRankRes
