local SInstanceNormalResult = class("SInstanceNormalResult")
SInstanceNormalResult.TYPEID = 12591373
SInstanceNormalResult.PERSON_COUNT_NOT_ENOUGH = 1
SInstanceNormalResult.LEVEL_NOT_ENOUGH = 2
SInstanceNormalResult.MEMBER_STATUS_WRONG = 3
SInstanceNormalResult.TEAM_LEADER_NOT_HAVE_ITEM = 5
SInstanceNormalResult.MEMBER_STATUS_OFFLINE = 6
SInstanceNormalResult.WAIT_MEMBER_OPERATION = 7
SInstanceNormalResult.SAO_DANG_CHENG_GONG = 10
SInstanceNormalResult.LEAVE_INSTANCE_NOT_AWARD = 11
SInstanceNormalResult.SINGLE_INSTANCE_FAIL_TIMES_NOT_ENOUGH = 20
function SInstanceNormalResult:ctor(result, args)
  self.id = 12591373
  self.result = result or nil
  self.args = args or {}
end
function SInstanceNormalResult:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SInstanceNormalResult:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SInstanceNormalResult:sizepolicy(size)
  return size <= 65535
end
return SInstanceNormalResult
