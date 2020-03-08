local SActiveNormalResult = class("SActiveNormalResult")
SActiveNormalResult.TYPEID = 12599557
SActiveNormalResult.TAKE_ACTIVE_AWARD_BAG_FULL = 1
SActiveNormalResult.TAKE_ACTIVE_AWARD_TO_MAX = 2
SActiveNormalResult.TAKE_ACTIVE_AWARD_UNKNOW_ERROR = 3
SActiveNormalResult.ACTIVE_AWARD_INDEX_ALEARDY_AWARD = 4
SActiveNormalResult.ACTIVE_AWARD_VALUE_NOT_ENOUGH = 5
SActiveNormalResult.ACTIVE_AWARD_FAILED = 6
SActiveNormalResult.ACTIVE_AWARD_LEVEL_NOT_FOUND = 7
SActiveNormalResult.ACTIVE_AWARD_INDEX_NOT_EXIST = 8
function SActiveNormalResult:ctor(result, args)
  self.id = 12599557
  self.result = result or nil
  self.args = args or {}
end
function SActiveNormalResult:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SActiveNormalResult:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SActiveNormalResult:sizepolicy(size)
  return size <= 65535
end
return SActiveNormalResult
