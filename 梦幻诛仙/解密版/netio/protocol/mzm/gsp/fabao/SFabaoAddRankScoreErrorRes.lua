local SFabaoAddRankScoreErrorRes = class("SFabaoAddRankScoreErrorRes")
SFabaoAddRankScoreErrorRes.TYPEID = 12596021
SFabaoAddRankScoreErrorRes.ERROR_UNKNOWN = 0
SFabaoAddRankScoreErrorRes.ERROR_CFG_NON_EXSIT = 1
SFabaoAddRankScoreErrorRes.ERROR_RANK_ITEM_TYPE = 2
SFabaoAddRankScoreErrorRes.ERROR_MAX_RANK_FA_BAO = 3
SFabaoAddRankScoreErrorRes.ERROR_RANK_ITEM_NON_EXIST = 7
SFabaoAddRankScoreErrorRes.ERROR_RANK_ITEM_COUNT_NOT_ENOUGH = 8
SFabaoAddRankScoreErrorRes.ERROR_RANK_ITEM_RANK_EXP_FULL = 9
SFabaoAddRankScoreErrorRes.ERROR_RANK_ITEM_NOT_SAME_TYPE = 10
SFabaoAddRankScoreErrorRes.ERROR_IN_CROSS = 11
SFabaoAddRankScoreErrorRes.ERROR_RANK_LEVEL_TOO_BIG = 12
function SFabaoAddRankScoreErrorRes:ctor(resultcode)
  self.id = 12596021
  self.resultcode = resultcode or nil
end
function SFabaoAddRankScoreErrorRes:marshal(os)
  os:marshalInt32(self.resultcode)
end
function SFabaoAddRankScoreErrorRes:unmarshal(os)
  self.resultcode = os:unmarshalInt32()
end
function SFabaoAddRankScoreErrorRes:sizepolicy(size)
  return size <= 65535
end
return SFabaoAddRankScoreErrorRes
