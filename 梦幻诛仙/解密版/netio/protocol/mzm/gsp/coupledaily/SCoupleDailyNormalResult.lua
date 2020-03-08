local SCoupleDailyNormalResult = class("SCoupleDailyNormalResult")
SCoupleDailyNormalResult.TYPEID = 12602373
SCoupleDailyNormalResult.ACTIVITY_DONE_REFORE = 0
SCoupleDailyNormalResult.PARTNER_ACTIVITY_DONE_REFORE = 1
SCoupleDailyNormalResult.PIN_TU_FAIL = 2
SCoupleDailyNormalResult.FIGHT_FAIL = 3
function SCoupleDailyNormalResult:ctor(result, args)
  self.id = 12602373
  self.result = result or nil
  self.args = args or {}
end
function SCoupleDailyNormalResult:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SCoupleDailyNormalResult:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SCoupleDailyNormalResult:sizepolicy(size)
  return size <= 65535
end
return SCoupleDailyNormalResult
