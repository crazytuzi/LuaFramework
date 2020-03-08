local SFabaoAddRankScoreRes = class("SFabaoAddRankScoreRes")
SFabaoAddRankScoreRes.TYPEID = 12595999
function SFabaoAddRankScoreRes:ctor(equiped, fabaouuid, addScore)
  self.id = 12595999
  self.equiped = equiped or nil
  self.fabaouuid = fabaouuid or nil
  self.addScore = addScore or nil
end
function SFabaoAddRankScoreRes:marshal(os)
  os:marshalInt32(self.equiped)
  os:marshalInt64(self.fabaouuid)
  os:marshalInt32(self.addScore)
end
function SFabaoAddRankScoreRes:unmarshal(os)
  self.equiped = os:unmarshalInt32()
  self.fabaouuid = os:unmarshalInt64()
  self.addScore = os:unmarshalInt32()
end
function SFabaoAddRankScoreRes:sizepolicy(size)
  return size <= 65535
end
return SFabaoAddRankScoreRes
