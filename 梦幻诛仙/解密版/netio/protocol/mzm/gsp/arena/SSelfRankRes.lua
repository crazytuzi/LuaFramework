local SSelfRankRes = class("SSelfRankRes")
SSelfRankRes.TYPEID = 12596746
function SSelfRankRes:ctor(score, rank)
  self.id = 12596746
  self.score = score or nil
  self.rank = rank or nil
end
function SSelfRankRes:marshal(os)
  os:marshalInt32(self.score)
  os:marshalInt32(self.rank)
end
function SSelfRankRes:unmarshal(os)
  self.score = os:unmarshalInt32()
  self.rank = os:unmarshalInt32()
end
function SSelfRankRes:sizepolicy(size)
  return size <= 65535
end
return SSelfRankRes
