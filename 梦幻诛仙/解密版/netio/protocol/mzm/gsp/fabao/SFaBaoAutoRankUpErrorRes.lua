local SFaBaoAutoRankUpErrorRes = class("SFaBaoAutoRankUpErrorRes")
SFaBaoAutoRankUpErrorRes.TYPEID = 12596042
SFaBaoAutoRankUpErrorRes.ERROR_UNKNOWN = 1
SFaBaoAutoRankUpErrorRes.ERROR_CFG_NON_EXSIT = 2
SFaBaoAutoRankUpErrorRes.ERROR_FABAO_TYPE = 3
SFaBaoAutoRankUpErrorRes.ERROR_MAX_RANK = 4
SFaBaoAutoRankUpErrorRes.ERROR_LV_NOT_ENOUGH = 5
SFaBaoAutoRankUpErrorRes.ERROR_UPRANK_ITEM = 6
SFaBaoAutoRankUpErrorRes.ERROR_MONEY_NOT_ENOUGH = 7
SFaBaoAutoRankUpErrorRes.ERROR_ITEM_PRICE_CHANGED = 8
SFaBaoAutoRankUpErrorRes.ERROR_ITEM_RANK_ALREADY = 9
SFaBaoAutoRankUpErrorRes.ERROR_IN_CROSS = 10
SFaBaoAutoRankUpErrorRes.ERROR_TARGET_RANK_ILLEGAL = 11
function SFaBaoAutoRankUpErrorRes:ctor(resultcode)
  self.id = 12596042
  self.resultcode = resultcode or nil
end
function SFaBaoAutoRankUpErrorRes:marshal(os)
  os:marshalInt32(self.resultcode)
end
function SFaBaoAutoRankUpErrorRes:unmarshal(os)
  self.resultcode = os:unmarshalInt32()
end
function SFaBaoAutoRankUpErrorRes:sizepolicy(size)
  return size <= 65535
end
return SFaBaoAutoRankUpErrorRes
