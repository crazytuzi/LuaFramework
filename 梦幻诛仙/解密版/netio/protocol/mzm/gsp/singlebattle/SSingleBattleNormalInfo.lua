local SSingleBattleNormalInfo = class("SSingleBattleNormalInfo")
SSingleBattleNormalInfo.TYPEID = 12621575
SSingleBattleNormalInfo.ATTACK_FORBID__OTHER_IN_FIGHT = 1
function SSingleBattleNormalInfo:ctor(result, args)
  self.id = 12621575
  self.result = result or nil
  self.args = args or {}
end
function SSingleBattleNormalInfo:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SSingleBattleNormalInfo:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SSingleBattleNormalInfo:sizepolicy(size)
  return size <= 65535
end
return SSingleBattleNormalInfo
