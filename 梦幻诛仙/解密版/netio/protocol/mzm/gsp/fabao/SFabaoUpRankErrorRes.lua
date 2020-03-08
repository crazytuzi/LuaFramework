local SFabaoUpRankErrorRes = class("SFabaoUpRankErrorRes")
SFabaoUpRankErrorRes.TYPEID = 12596005
SFabaoUpRankErrorRes.ERROR_UNKNOWN = 1
SFabaoUpRankErrorRes.ERROR_CFG_NON_EXSIT = 2
SFabaoUpRankErrorRes.ERROR_FABAO_TYPE = 3
SFabaoUpRankErrorRes.ERROR_MAX_RANK = 4
SFabaoUpRankErrorRes.ERROR_LV_NOT_ENOUGH = 5
SFabaoUpRankErrorRes.ERROR_UPRANK_ITEM = 6
SFabaoUpRankErrorRes.ERROR_MONEY_NOT_ENOUGH = 7
SFabaoUpRankErrorRes.ERROR_ITEM_PRICE_CHANGED = 8
SFabaoUpRankErrorRes.ERROR_ITEM_RANK_ALREADY = 9
SFabaoUpRankErrorRes.ERROR_ITEM_RANK_EXP = 10
SFabaoUpRankErrorRes.ERROR_IN_CROSS = 11
function SFabaoUpRankErrorRes:ctor(resultcode)
  self.id = 12596005
  self.resultcode = resultcode or nil
end
function SFabaoUpRankErrorRes:marshal(os)
  os:marshalInt32(self.resultcode)
end
function SFabaoUpRankErrorRes:unmarshal(os)
  self.resultcode = os:unmarshalInt32()
end
function SFabaoUpRankErrorRes:sizepolicy(size)
  return size <= 65535
end
return SFabaoUpRankErrorRes
