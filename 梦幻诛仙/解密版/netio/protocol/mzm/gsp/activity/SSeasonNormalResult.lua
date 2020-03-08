local SSeasonNormalResult = class("SSeasonNormalResult")
SSeasonNormalResult.TYPEID = 12587574
SSeasonNormalResult.JOIN_ACTIVITY_MULTI_ERROR__NOT_LEADER = 1
SSeasonNormalResult.JOIN_ACTIVITY_MULTI_ERROR__NOT_ENOUGH_PEOPLE = 2
SSeasonNormalResult.JOIN_ACTIVITY_MULTI_ERROR__TEAM_CHANGE = 3
SSeasonNormalResult.JOIN_ACTIVITY_MULTI_ERROR__ALREADY_DONE = 4
SSeasonNormalResult.JOIN_ACTIVITY_ERROR__NOT_NEAR_NPC = 5
SSeasonNormalResult.AWARD_MULTI_ERROR__ALREADY_DONE = 6
SSeasonNormalResult.JOIN_ACTIVITY_SINGLE_ERROR__DONE = 20
SSeasonNormalResult.JOIN_ACTIVITY_SINGLE__DONE = 21
function SSeasonNormalResult:ctor(result, args)
  self.id = 12587574
  self.result = result or nil
  self.args = args or {}
end
function SSeasonNormalResult:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SSeasonNormalResult:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SSeasonNormalResult:sizepolicy(size)
  return size <= 65535
end
return SSeasonNormalResult
