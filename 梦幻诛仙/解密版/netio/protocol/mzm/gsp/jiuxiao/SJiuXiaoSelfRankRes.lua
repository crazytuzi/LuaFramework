local SJiuXiaoSelfRankRes = class("SJiuXiaoSelfRankRes")
SJiuXiaoSelfRankRes.TYPEID = 12595474
function SJiuXiaoSelfRankRes:ctor(rankType, rank, layer, time)
  self.id = 12595474
  self.rankType = rankType or nil
  self.rank = rank or nil
  self.layer = layer or nil
  self.time = time or nil
end
function SJiuXiaoSelfRankRes:marshal(os)
  os:marshalInt32(self.rankType)
  os:marshalInt32(self.rank)
  os:marshalInt32(self.layer)
  os:marshalInt32(self.time)
end
function SJiuXiaoSelfRankRes:unmarshal(os)
  self.rankType = os:unmarshalInt32()
  self.rank = os:unmarshalInt32()
  self.layer = os:unmarshalInt32()
  self.time = os:unmarshalInt32()
end
function SJiuXiaoSelfRankRes:sizepolicy(size)
  return size <= 65535
end
return SJiuXiaoSelfRankRes
