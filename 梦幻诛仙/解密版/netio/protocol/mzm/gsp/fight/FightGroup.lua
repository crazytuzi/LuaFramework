local OctetsStream = require("netio.OctetsStream")
local FightGroup = class("FightGroup")
FightGroup.TYPE_ROLE = 0
FightGroup.TYPE_MONSTER = 1
FightGroup.TYPE_FELLOW = 2
function FightGroup:ctor(group_type, fighters, roleid, useitemtimes, summonPettimes, summonChldtimes, fightedPets, fightedChilds)
  self.group_type = group_type or nil
  self.fighters = fighters or {}
  self.roleid = roleid or nil
  self.useitemtimes = useitemtimes or nil
  self.summonPettimes = summonPettimes or nil
  self.summonChldtimes = summonChldtimes or nil
  self.fightedPets = fightedPets or {}
  self.fightedChilds = fightedChilds or {}
end
function FightGroup:marshal(os)
  os:marshalInt32(self.group_type)
  do
    local _size_ = 0
    for _, _ in pairs(self.fighters) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.fighters) do
      os:marshalInt32(k)
      v:marshal(os)
    end
  end
  os:marshalInt64(self.roleid)
  os:marshalInt32(self.useitemtimes)
  os:marshalInt32(self.summonPettimes)
  os:marshalInt32(self.summonChldtimes)
  do
    local _size_ = 0
    for _, _ in pairs(self.fightedPets) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, _ in pairs(self.fightedPets) do
      os:marshalInt64(k)
    end
  end
  local _size_ = 0
  for _, _ in pairs(self.fightedChilds) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, _ in pairs(self.fightedChilds) do
    os:marshalInt64(k)
  end
end
function FightGroup:unmarshal(os)
  self.group_type = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.fight.Fighter")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.fighters[k] = v
  end
  self.roleid = os:unmarshalInt64()
  self.useitemtimes = os:unmarshalInt32()
  self.summonPettimes = os:unmarshalInt32()
  self.summonChldtimes = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    self.fightedPets[v] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    self.fightedChilds[v] = v
  end
end
return FightGroup
