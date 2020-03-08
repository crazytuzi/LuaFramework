local SSyncHeroProp = class("SSyncHeroProp")
SSyncHeroProp.TYPEID = 12586007
SSyncHeroProp.MAIL = 1
SSyncHeroProp.FEMAIL = 2
SSyncHeroProp.PROP_SYS_1 = 0
SSyncHeroProp.PROP_SYS_2 = 1
SSyncHeroProp.PROP_SYS_3 = 2
function SSyncHeroProp:ctor(roleid, name, occupation, gender, level, appelation, exp, hp, mp, vigor, anger, propMap, propSysMap, activityPropSys, todayActivityCount, fightValue, createTime)
  self.id = 12586007
  self.roleid = roleid or nil
  self.name = name or nil
  self.occupation = occupation or nil
  self.gender = gender or nil
  self.level = level or nil
  self.appelation = appelation or nil
  self.exp = exp or nil
  self.hp = hp or nil
  self.mp = mp or nil
  self.vigor = vigor or nil
  self.anger = anger or nil
  self.propMap = propMap or {}
  self.propSysMap = propSysMap or {}
  self.activityPropSys = activityPropSys or nil
  self.todayActivityCount = todayActivityCount or nil
  self.fightValue = fightValue or nil
  self.createTime = createTime or nil
end
function SSyncHeroProp:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalString(self.name)
  os:marshalInt32(self.occupation)
  os:marshalInt32(self.gender)
  os:marshalInt32(self.level)
  os:marshalInt32(self.appelation)
  os:marshalInt64(self.exp)
  os:marshalInt32(self.hp)
  os:marshalInt32(self.mp)
  os:marshalInt32(self.vigor)
  os:marshalInt32(self.anger)
  do
    local _size_ = 0
    for _, _ in pairs(self.propMap) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.propMap) do
      os:marshalInt32(k)
      os:marshalInt32(v)
    end
  end
  do
    local _size_ = 0
    for _, _ in pairs(self.propSysMap) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.propSysMap) do
      os:marshalInt32(k)
      v:marshal(os)
    end
  end
  os:marshalInt32(self.activityPropSys)
  os:marshalInt32(self.todayActivityCount)
  os:marshalInt32(self.fightValue)
  os:marshalInt64(self.createTime)
end
function SSyncHeroProp:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.name = os:unmarshalString()
  self.occupation = os:unmarshalInt32()
  self.gender = os:unmarshalInt32()
  self.level = os:unmarshalInt32()
  self.appelation = os:unmarshalInt32()
  self.exp = os:unmarshalInt64()
  self.hp = os:unmarshalInt32()
  self.mp = os:unmarshalInt32()
  self.vigor = os:unmarshalInt32()
  self.anger = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.propMap[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.role.PropSys")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.propSysMap[k] = v
  end
  self.activityPropSys = os:unmarshalInt32()
  self.todayActivityCount = os:unmarshalInt32()
  self.fightValue = os:unmarshalInt32()
  self.createTime = os:unmarshalInt64()
end
function SSyncHeroProp:sizepolicy(size)
  return size <= 65535
end
return SSyncHeroProp
