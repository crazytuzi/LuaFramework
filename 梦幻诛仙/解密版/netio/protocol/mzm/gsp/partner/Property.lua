local OctetsStream = require("netio.OctetsStream")
local Property = class("Property")
function Property:ctor(hp, maxHp, mp, maxMp, phyAtk, phyDef, magAtk, magDef, speed, magCrt, phyCrt, sealRes, fightValue, skills, loves, lovesToReplace, yuanLv, levels, skillInfos)
  self.hp = hp or nil
  self.maxHp = maxHp or nil
  self.mp = mp or nil
  self.maxMp = maxMp or nil
  self.phyAtk = phyAtk or nil
  self.phyDef = phyDef or nil
  self.magAtk = magAtk or nil
  self.magDef = magDef or nil
  self.speed = speed or nil
  self.magCrt = magCrt or nil
  self.phyCrt = phyCrt or nil
  self.sealRes = sealRes or nil
  self.fightValue = fightValue or nil
  self.skills = skills or {}
  self.loves = loves or {}
  self.lovesToReplace = lovesToReplace or {}
  self.yuanLv = yuanLv or nil
  self.levels = levels or {}
  self.skillInfos = skillInfos or {}
end
function Property:marshal(os)
  os:marshalInt32(self.hp)
  os:marshalInt32(self.maxHp)
  os:marshalInt32(self.mp)
  os:marshalInt32(self.maxMp)
  os:marshalInt32(self.phyAtk)
  os:marshalInt32(self.phyDef)
  os:marshalInt32(self.magAtk)
  os:marshalInt32(self.magDef)
  os:marshalInt32(self.speed)
  os:marshalInt32(self.magCrt)
  os:marshalInt32(self.phyCrt)
  os:marshalInt32(self.sealRes)
  os:marshalInt32(self.fightValue)
  os:marshalCompactUInt32(table.getn(self.skills))
  for _, v in ipairs(self.skills) do
    os:marshalInt32(v)
  end
  os:marshalCompactUInt32(table.getn(self.loves))
  for _, v in ipairs(self.loves) do
    os:marshalInt32(v)
  end
  os:marshalCompactUInt32(table.getn(self.lovesToReplace))
  for _, v in ipairs(self.lovesToReplace) do
    os:marshalInt32(v)
  end
  os:marshalInt32(self.yuanLv)
  os:marshalCompactUInt32(table.getn(self.levels))
  for _, v in ipairs(self.levels) do
    os:marshalInt32(v)
  end
  local _size_ = 0
  for _, _ in pairs(self.skillInfos) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.skillInfos) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function Property:unmarshal(os)
  self.hp = os:unmarshalInt32()
  self.maxHp = os:unmarshalInt32()
  self.mp = os:unmarshalInt32()
  self.maxMp = os:unmarshalInt32()
  self.phyAtk = os:unmarshalInt32()
  self.phyDef = os:unmarshalInt32()
  self.magAtk = os:unmarshalInt32()
  self.magDef = os:unmarshalInt32()
  self.speed = os:unmarshalInt32()
  self.magCrt = os:unmarshalInt32()
  self.phyCrt = os:unmarshalInt32()
  self.sealRes = os:unmarshalInt32()
  self.fightValue = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.skills, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.loves, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.lovesToReplace, v)
  end
  self.yuanLv = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.levels, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.skillInfos[k] = v
  end
end
return Property
