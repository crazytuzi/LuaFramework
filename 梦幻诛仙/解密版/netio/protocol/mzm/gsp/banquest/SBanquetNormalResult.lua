local SBanquetNormalResult = class("SBanquetNormalResult")
SBanquetNormalResult.TYPEID = 12605955
SBanquetNormalResult.BANQUEST_AWARD_UPPER_LIMIT = 1
SBanquetNormalResult.EACH_BANQUEST_AWARD_UPPER_LIMIT = 2
SBanquetNormalResult.EACH_DISH_AWARD_UPPER_LIMIT = 3
SBanquetNormalResult.HOLD_BANQUEST_COUNT_MAX = 4
SBanquetNormalResult.HOLD_BANQUEST_MAST_BE_CREATOR = 5
SBanquetNormalResult.HOLD_BANQUEST_REPEAT = 6
SBanquetNormalResult.JOIN_BANQUEST_LV_ILLEGAL = 7
SBanquetNormalResult.JOIN_BANQUEST_MEMBER_LV_ILLEGAL = 8
SBanquetNormalResult.HOLD_BANQUEST_BAN__NUM_TO_MAX = 9
function SBanquetNormalResult:ctor(result, args)
  self.id = 12605955
  self.result = result or nil
  self.args = args or {}
end
function SBanquetNormalResult:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SBanquetNormalResult:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SBanquetNormalResult:sizepolicy(size)
  return size <= 65535
end
return SBanquetNormalResult
