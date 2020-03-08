local CGetCrossFieldRankReq = class("CGetCrossFieldRankReq")
CGetCrossFieldRankReq.TYPEID = 12619532
function CGetCrossFieldRankReq:ctor(rankType, startpos, num)
  self.id = 12619532
  self.rankType = rankType or nil
  self.startpos = startpos or nil
  self.num = num or nil
end
function CGetCrossFieldRankReq:marshal(os)
  os:marshalInt32(self.rankType)
  os:marshalInt32(self.startpos)
  os:marshalInt32(self.num)
end
function CGetCrossFieldRankReq:unmarshal(os)
  self.rankType = os:unmarshalInt32()
  self.startpos = os:unmarshalInt32()
  self.num = os:unmarshalInt32()
end
function CGetCrossFieldRankReq:sizepolicy(size)
  return size <= 65535
end
return CGetCrossFieldRankReq
