local CLadderRankReq = class("CLadderRankReq")
CLadderRankReq.TYPEID = 12607270
function CLadderRankReq:ctor(rankType, fromNo, toNo)
  self.id = 12607270
  self.rankType = rankType or nil
  self.fromNo = fromNo or nil
  self.toNo = toNo or nil
end
function CLadderRankReq:marshal(os)
  os:marshalInt32(self.rankType)
  os:marshalInt32(self.fromNo)
  os:marshalInt32(self.toNo)
end
function CLadderRankReq:unmarshal(os)
  self.rankType = os:unmarshalInt32()
  self.fromNo = os:unmarshalInt32()
  self.toNo = os:unmarshalInt32()
end
function CLadderRankReq:sizepolicy(size)
  return size <= 65535
end
return CLadderRankReq
