local OctetsStream = require("netio.OctetsStream")
local ModelInfo = require("netio.protocol.mzm.gsp.pubdata.ModelInfo")
local FighterStatus = require("netio.protocol.mzm.gsp.fight.FighterStatus")
local Fighter = class("Fighter")
function Fighter:ctor(fighter_type, uuid, cfgid, name, level, occupation, gender, pos, model, status, skillDatas)
  self.fighter_type = fighter_type or nil
  self.uuid = uuid or nil
  self.cfgid = cfgid or nil
  self.name = name or nil
  self.level = level or nil
  self.occupation = occupation or nil
  self.gender = gender or nil
  self.pos = pos or nil
  self.model = model or ModelInfo.new()
  self.status = status or FighterStatus.new()
  self.skillDatas = skillDatas or {}
end
function Fighter:marshal(os)
  os:marshalInt32(self.fighter_type)
  os:marshalInt64(self.uuid)
  os:marshalInt32(self.cfgid)
  os:marshalString(self.name)
  os:marshalInt32(self.level)
  os:marshalInt32(self.occupation)
  os:marshalInt32(self.gender)
  os:marshalInt32(self.pos)
  self.model:marshal(os)
  self.status:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.skillDatas) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.skillDatas) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function Fighter:unmarshal(os)
  self.fighter_type = os:unmarshalInt32()
  self.uuid = os:unmarshalInt64()
  self.cfgid = os:unmarshalInt32()
  self.name = os:unmarshalString()
  self.level = os:unmarshalInt32()
  self.occupation = os:unmarshalInt32()
  self.gender = os:unmarshalInt32()
  self.pos = os:unmarshalInt32()
  self.model = ModelInfo.new()
  self.model:unmarshal(os)
  self.status = FighterStatus.new()
  self.status:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.fight.SkillData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.skillDatas[k] = v
  end
end
return Fighter
