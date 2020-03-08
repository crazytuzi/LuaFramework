local OctetsStream = require("netio.OctetsStream")
local FighterStatus = class("FighterStatus")
FighterStatus.STATUS_ALIVE = 0
FighterStatus.STATUS_DEAD = 1
FighterStatus.STATUS_ESCAPED = 2
FighterStatus.STATUS_FAKE_DEAD = 3
FighterStatus.STATUS_ATTACKED = 20
FighterStatus.STATUS_CRITICAL_ATTACK = 21
FighterStatus.STATUS_DODGE = 22
FighterStatus.STATUS_RELIVE = 23
FighterStatus.STATUS_COMBO_ATTACKED = 24
FighterStatus.STATUS_ABSORB_DAMAGE = 26
FighterStatus.STATUS_PROTECT_OTHER = 27
FighterStatus.STATUS_COUNTER_ATTACK = 28
FighterStatus.STATUS_DEFENSE = 29
FighterStatus.STATUS_SEAL_NOT_HIT = 30
FighterStatus.STATUS_IMMUNE = 31
FighterStatus.STATUS_BLACKHOLE_DAMAGE = 32
FighterStatus.STATUS_LIFELINK_DAMAGE = 33
FighterStatus.STATUS_RELIVE_TIME_BACK = 34
FighterStatus.BUFF_ST__REST = 100
FighterStatus.BUFF_ST__SLEEP = 101
FighterStatus.BUFF_ST__STONE = 102
FighterStatus.BUFF_ST__MESS = 103
FighterStatus.BUFF_ST__SEAL = 104
FighterStatus.BUFF_ST__HOUFA = 105
FighterStatus.BUFF_ST__FORBIDREBIRTH = 106
FighterStatus.BUFF_ST__INVISIBLE = 107
FighterStatus.BUFF_ST__VISIBLE = 108
FighterStatus.BUFF_ST__DEFENCE = 109
FighterStatus.BUFF_ST__WEAK = 110
FighterStatus.BUFF_ST__TECH = 111
FighterStatus.BUFF_ST__FORTUNE = 112
FighterStatus.BUFF_ST__GHOST = 113
FighterStatus.BUFF_ST__BEAT_GHOST = 114
FighterStatus.BUFF_ST__PERSISTENT = 115
FighterStatus.BUFF_ST__FLY = 116
FighterStatus.BUFF_ST__AGILE = 117
FighterStatus.BUFF_ST__ACCURATE = 118
FighterStatus.BUFF_ST__FEAR = 119
FighterStatus.BUFF_ST__SINCERELY = 120
FighterStatus.BUFF_ST__TRIAL = 121
FighterStatus.BUFF_ST__BARRIERS = 122
FighterStatus.BUFF_ST__BREAK_BARRIERS = 123
FighterStatus.BUFF_ST__PARRY = 124
FighterStatus.BUFF_ST__PROPERTY_RELIVE = 125
FighterStatus.BUFF_ST__IMMUNE = 126
FighterStatus.BUFF_ST__TAUNT = 127
FighterStatus.BUFF_ST__ICECOOL = 128
FighterStatus.BUFF_ST__NOTLEAVE = 129
FighterStatus.BUFF_ST__DEATHSKILL = 130
FighterStatus.BUFF_ST__SUBSOULBOND = 131
FighterStatus.BUFF_ST__RELEASE_SKILL_DEAD = 132
FighterStatus.BUFF_ST__MARK = 133
FighterStatus.BUFF_ST__HOUFA_MISSILE = 134
FighterStatus.BUFF_ST__MIRROR_SKILL = 135
function FighterStatus:ctor(hpchange, mpchange, angerchange, status_set, buff_status_set, buffs, hpMax, curHp, mpMax, curMp, angerMax, curAnger, curEnergy, changeModels, triggerPassiveSkills)
  self.hpchange = hpchange or nil
  self.mpchange = mpchange or nil
  self.angerchange = angerchange or nil
  self.status_set = status_set or {}
  self.buff_status_set = buff_status_set or {}
  self.buffs = buffs or {}
  self.hpMax = hpMax or nil
  self.curHp = curHp or nil
  self.mpMax = mpMax or nil
  self.curMp = curMp or nil
  self.angerMax = angerMax or nil
  self.curAnger = curAnger or nil
  self.curEnergy = curEnergy or nil
  self.changeModels = changeModels or {}
  self.triggerPassiveSkills = triggerPassiveSkills or {}
end
function FighterStatus:marshal(os)
  os:marshalInt32(self.hpchange)
  os:marshalInt32(self.mpchange)
  os:marshalInt32(self.angerchange)
  do
    local _size_ = 0
    for _, _ in pairs(self.status_set) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, _ in pairs(self.status_set) do
      os:marshalInt32(k)
    end
  end
  do
    local _size_ = 0
    for _, _ in pairs(self.buff_status_set) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, _ in pairs(self.buff_status_set) do
      os:marshalInt32(k)
    end
  end
  os:marshalCompactUInt32(table.getn(self.buffs))
  for _, v in ipairs(self.buffs) do
    v:marshal(os)
  end
  os:marshalInt32(self.hpMax)
  os:marshalInt32(self.curHp)
  os:marshalInt32(self.mpMax)
  os:marshalInt32(self.curMp)
  os:marshalInt32(self.angerMax)
  os:marshalInt32(self.curAnger)
  os:marshalInt32(self.curEnergy)
  do
    local _size_ = 0
    for _, _ in pairs(self.changeModels) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, _ in pairs(self.changeModels) do
      os:marshalInt32(k)
    end
  end
  local _size_ = 0
  for _, _ in pairs(self.triggerPassiveSkills) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, _ in pairs(self.triggerPassiveSkills) do
    os:marshalInt32(k)
  end
end
function FighterStatus:unmarshal(os)
  self.hpchange = os:unmarshalInt32()
  self.mpchange = os:unmarshalInt32()
  self.angerchange = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    self.status_set[v] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    self.buff_status_set[v] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.fight.Buff")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.buffs, v)
  end
  self.hpMax = os:unmarshalInt32()
  self.curHp = os:unmarshalInt32()
  self.mpMax = os:unmarshalInt32()
  self.curMp = os:unmarshalInt32()
  self.angerMax = os:unmarshalInt32()
  self.curAnger = os:unmarshalInt32()
  self.curEnergy = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    self.changeModels[v] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    self.triggerPassiveSkills[v] = v
  end
end
return FighterStatus
