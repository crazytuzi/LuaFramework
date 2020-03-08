local SAwardNormalResult = class("SAwardNormalResult")
SAwardNormalResult.TYPEID = 12583433
SAwardNormalResult.MULTI_AWARD_INDEX_ALREADY_SELECTED = 1
SAwardNormalResult.GOLD_NUM_REACH_TOP_LIMIT = 21
SAwardNormalResult.SILVER_NUM_REACH_TOP_LIMIT = 22
SAwardNormalResult.TOKEN_NUM_REACH_TOP_LIMIT = 23
SAwardNormalResult.BAG_FULL_CANNOT_AWARD = 24
SAwardNormalResult.ADD_XX_REACH_MAX_VALUE = 25
SAwardNormalResult.ADD_STOR_EXP_REACH_MAX_VALUE = 26
SAwardNormalResult.GOLD_INGOT_NUM_REACH_TOP_LIMIT = 27
SAwardNormalResult.AWARD_ERROR__WITHOUT_FACTION = 30
function SAwardNormalResult:ctor(result, args)
  self.id = 12583433
  self.result = result or nil
  self.args = args or {}
end
function SAwardNormalResult:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SAwardNormalResult:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SAwardNormalResult:sizepolicy(size)
  return size <= 65535
end
return SAwardNormalResult
