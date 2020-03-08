local SArenaNormalResult = class("SArenaNormalResult")
SArenaNormalResult.TYPEID = 12596737
SArenaNormalResult.ENTER_ARENA_MAP__SELF_NO_ACTION_POINT = 1
SArenaNormalResult.ENTER_ARENA_MAP__OTHER_NO_ACTION_POINT = 2
SArenaNormalResult.ENTER_ARENA_MAP__SELF_PARTICIPATED = 3
SArenaNormalResult.ENTER_ARENA_MAP__OTHER_PARTICIPATED = 4
SArenaNormalResult.ENTER_ARENA_MAP__DIFF_CAMP = 5
SArenaNormalResult.ENTER_ARENA_MAP__TEAM_STATUS = 6
SArenaNormalResult.ENTER_ARENA_MAP__NOT_ACTIVITY_TIME = 7
SArenaNormalResult.ENTER_ARENA_MAP__END = 8
SArenaNormalResult.LEAVE_ARENA_MAP__LACK_ACTION_POINT = 11
SArenaNormalResult.LEAVE_ARENA_MAP__IN_TEAM = 12
function SArenaNormalResult:ctor(result, args)
  self.id = 12596737
  self.result = result or nil
  self.args = args or {}
end
function SArenaNormalResult:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SArenaNormalResult:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SArenaNormalResult:sizepolicy(size)
  return size <= 65535
end
return SArenaNormalResult
