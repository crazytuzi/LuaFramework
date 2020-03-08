local OctetsStream = require("netio.OctetsStream")
local FighterStatus = require("netio.protocol.mzm.gsp.fight.FighterStatus")
local InfluenceOther = require("netio.protocol.mzm.gsp.fight.InfluenceOther")
local CounterAttack = class("CounterAttack")
CounterAttack.REBOUND = 0
CounterAttack.TARGET_RELIVE = 1
CounterAttack.RELEASER_RELIVE = 2
function CounterAttack:ctor(skill, attackerStatus, targetStatus, statusMap, influences)
  self.skill = skill or nil
  self.attackerStatus = attackerStatus or FighterStatus.new()
  self.targetStatus = targetStatus or FighterStatus.new()
  self.statusMap = statusMap or {}
  self.influences = influences or InfluenceOther.new()
end
function CounterAttack:marshal(os)
  os:marshalInt32(self.skill)
  self.attackerStatus:marshal(os)
  self.targetStatus:marshal(os)
  do
    local _size_ = 0
    for _, _ in pairs(self.statusMap) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.statusMap) do
      os:marshalInt32(k)
      v:marshal(os)
    end
  end
  self.influences:marshal(os)
end
function CounterAttack:unmarshal(os)
  self.skill = os:unmarshalInt32()
  self.attackerStatus = FighterStatus.new()
  self.attackerStatus:unmarshal(os)
  self.targetStatus = FighterStatus.new()
  self.targetStatus:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.fight.FighterStatus")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.statusMap[k] = v
  end
  self.influences = InfluenceOther.new()
  self.influences:unmarshal(os)
end
return CounterAttack
