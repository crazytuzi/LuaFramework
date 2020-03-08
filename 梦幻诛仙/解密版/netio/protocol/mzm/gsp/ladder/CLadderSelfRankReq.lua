local CLadderSelfRankReq = class("CLadderSelfRankReq")
CLadderSelfRankReq.TYPEID = 12607273
function CLadderSelfRankReq:ctor(rankType)
  self.id = 12607273
  self.rankType = rankType or nil
end
function CLadderSelfRankReq:marshal(os)
  os:marshalInt32(self.rankType)
end
function CLadderSelfRankReq:unmarshal(os)
  self.rankType = os:unmarshalInt32()
end
function CLadderSelfRankReq:sizepolicy(size)
  return size <= 65535
end
return CLadderSelfRankReq
