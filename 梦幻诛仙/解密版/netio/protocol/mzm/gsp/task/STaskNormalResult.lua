local STaskNormalResult = class("STaskNormalResult")
STaskNormalResult.TYPEID = 12592132
STaskNormalResult.ACCEPT_TASK_REP_SETLIMIT = 1
STaskNormalResult.CAN_NOT_BATTLE_MIN_NUM = 2
STaskNormalResult.ALL_HAVE_TASK_CAN_BATTLE = 3
STaskNormalResult.SING_TASK_CANNOT_IN_TEAM = 4
STaskNormalResult.CAN_NOT_BATTLE_MIN_LEVEL = 5
STaskNormalResult.TASK_AWARD_BANED = 6
function STaskNormalResult:ctor(result, args)
  self.id = 12592132
  self.result = result or nil
  self.args = args or {}
end
function STaskNormalResult:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function STaskNormalResult:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function STaskNormalResult:sizepolicy(size)
  return size <= 65535
end
return STaskNormalResult
