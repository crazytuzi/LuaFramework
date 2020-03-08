local CJiuXiaoSelfRankReq = class("CJiuXiaoSelfRankReq")
CJiuXiaoSelfRankReq.TYPEID = 12595475
function CJiuXiaoSelfRankReq:ctor(rankType)
  self.id = 12595475
  self.rankType = rankType or nil
end
function CJiuXiaoSelfRankReq:marshal(os)
  os:marshalInt32(self.rankType)
end
function CJiuXiaoSelfRankReq:unmarshal(os)
  self.rankType = os:unmarshalInt32()
end
function CJiuXiaoSelfRankReq:sizepolicy(size)
  return size <= 65535
end
return CJiuXiaoSelfRankReq
