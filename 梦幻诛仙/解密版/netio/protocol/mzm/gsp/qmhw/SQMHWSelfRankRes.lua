local SQMHWSelfRankRes = class("SQMHWSelfRankRes")
SQMHWSelfRankRes.TYPEID = 12601868
function SQMHWSelfRankRes:ctor(rank, score)
  self.id = 12601868
  self.rank = rank or nil
  self.score = score or nil
end
function SQMHWSelfRankRes:marshal(os)
  os:marshalInt32(self.rank)
  os:marshalInt32(self.score)
end
function SQMHWSelfRankRes:unmarshal(os)
  self.rank = os:unmarshalInt32()
  self.score = os:unmarshalInt32()
end
function SQMHWSelfRankRes:sizepolicy(size)
  return size <= 65535
end
return SQMHWSelfRankRes
