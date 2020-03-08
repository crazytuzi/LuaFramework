local SFightNormalResult = class("SFightNormalResult")
SFightNormalResult.TYPEID = 12594184
SFightNormalResult.PLAYER_CAN_NOT_INFIGHT = 1
SFightNormalResult.PLAYER_FIGHT_END = 100
SFightNormalResult.PLAYER_IN_FIGHT = 101
SFightNormalResult.FIGHT_CFG_NOT_EXSIT = 102
SFightNormalResult.OBSERVER_TO_MAX = 103
SFightNormalResult.OBSERVE_FIGHT_NOT_EXIST = 104
SFightNormalResult.COMMAND_NANE_WRONG = 201
SFightNormalResult.COMMAND_NANE_SENSITIVE = 202
SFightNormalResult.OBERVER_FIGHT_OK = 301
SFightNormalResult.OBERVER_FIGHT_FAIL_NOT_IN_SAME_WORLD = 302
function SFightNormalResult:ctor(result, args)
  self.id = 12594184
  self.result = result or nil
  self.args = args or {}
end
function SFightNormalResult:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SFightNormalResult:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SFightNormalResult:sizepolicy(size)
  return size <= 65535
end
return SFightNormalResult
