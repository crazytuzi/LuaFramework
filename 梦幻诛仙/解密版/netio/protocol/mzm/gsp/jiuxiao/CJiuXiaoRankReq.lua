local CJiuXiaoRankReq = class("CJiuXiaoRankReq")
CJiuXiaoRankReq.TYPEID = 12595471
function CJiuXiaoRankReq:ctor(rankType, fromNo, toNo)
  self.id = 12595471
  self.rankType = rankType or nil
  self.fromNo = fromNo or nil
  self.toNo = toNo or nil
end
function CJiuXiaoRankReq:marshal(os)
  os:marshalInt32(self.rankType)
  os:marshalInt32(self.fromNo)
  os:marshalInt32(self.toNo)
end
function CJiuXiaoRankReq:unmarshal(os)
  self.rankType = os:unmarshalInt32()
  self.fromNo = os:unmarshalInt32()
  self.toNo = os:unmarshalInt32()
end
function CJiuXiaoRankReq:sizepolicy(size)
  return size <= 65535
end
return CJiuXiaoRankReq
