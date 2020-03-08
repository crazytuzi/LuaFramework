local OctetsStream = require("netio.OctetsStream")
local FighterStatus = require("netio.protocol.mzm.gsp.fight.FighterStatus")
local CounterAttack = require("netio.protocol.mzm.gsp.fight.CounterAttack")
local AttackOtherBeanResult = class("AttackOtherBeanResult")
function AttackOtherBeanResult:ctor(attackerStatus, targetStatus, shareDamageTargets, counterAttack, statusMap)
  self.attackerStatus = attackerStatus or FighterStatus.new()
  self.targetStatus = targetStatus or FighterStatus.new()
  self.shareDamageTargets = shareDamageTargets or {}
  self.counterAttack = counterAttack or CounterAttack.new()
  self.statusMap = statusMap or {}
end
function AttackOtherBeanResult:marshal(os)
  self.attackerStatus:marshal(os)
  self.targetStatus:marshal(os)
  os:marshalCompactUInt32(table.getn(self.shareDamageTargets))
  for _, v in ipairs(self.shareDamageTargets) do
    v:marshal(os)
  end
  self.counterAttack:marshal(os)
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
function AttackOtherBeanResult:unmarshal(os)
  self.attackerStatus = FighterStatus.new()
  self.attackerStatus:unmarshal(os)
  self.targetStatus = FighterStatus.new()
  self.targetStatus:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.fight.ShareDamageRet")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.shareDamageTargets, v)
  end
  self.counterAttack = CounterAttack.new()
  self.counterAttack:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.fight.FighterStatus")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.statusMap[k] = v
  end
end
return AttackOtherBeanResult
