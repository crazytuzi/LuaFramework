local OctetsStream = require("netio.OctetsStream")
local OpSummonMonster = class("OpSummonMonster")
OpSummonMonster.SAME_TEAM = 0
OpSummonMonster.NOT_SAME_TEAM = 1
function OpSummonMonster:ctor(monsterids, positions, level, sameTeam)
  self.monsterids = monsterids or {}
  self.positions = positions or {}
  self.level = level or nil
  self.sameTeam = sameTeam or nil
end
function OpSummonMonster:marshal(os)
  os:marshalCompactUInt32(table.getn(self.monsterids))
  for _, v in ipairs(self.monsterids) do
    os:marshalInt32(v)
  end
  os:marshalCompactUInt32(table.getn(self.positions))
  for _, v in ipairs(self.positions) do
    os:marshalInt32(v)
  end
  os:marshalInt32(self.level)
  os:marshalInt32(self.sameTeam)
end
function OpSummonMonster:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.monsterids, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.positions, v)
  end
  self.level = os:unmarshalInt32()
  self.sameTeam = os:unmarshalInt32()
end
return OpSummonMonster
