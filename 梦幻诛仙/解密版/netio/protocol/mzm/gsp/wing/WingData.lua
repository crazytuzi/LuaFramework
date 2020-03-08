local OctetsStream = require("netio.OctetsStream")
local WingData = class("WingData")
function WingData:ctor(cfgId, colorId, reProIds, reSkillIds, proIds, skills, target_skills)
  self.cfgId = cfgId or nil
  self.colorId = colorId or nil
  self.reProIds = reProIds or {}
  self.reSkillIds = reSkillIds or {}
  self.proIds = proIds or {}
  self.skills = skills or {}
  self.target_skills = target_skills or {}
end
function WingData:marshal(os)
  os:marshalInt32(self.cfgId)
  os:marshalInt32(self.colorId)
  os:marshalCompactUInt32(table.getn(self.reProIds))
  for _, v in ipairs(self.reProIds) do
    os:marshalInt32(v)
  end
  os:marshalCompactUInt32(table.getn(self.reSkillIds))
  for _, v in ipairs(self.reSkillIds) do
    os:marshalInt32(v)
  end
  os:marshalCompactUInt32(table.getn(self.proIds))
  for _, v in ipairs(self.proIds) do
    os:marshalInt32(v)
  end
  os:marshalCompactUInt32(table.getn(self.skills))
  for _, v in ipairs(self.skills) do
    os:marshalInt32(v)
  end
  local _size_ = 0
  for _, _ in pairs(self.target_skills) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.target_skills) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function WingData:unmarshal(os)
  self.cfgId = os:unmarshalInt32()
  self.colorId = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.reProIds, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.reSkillIds, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.proIds, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.skills, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.target_skills[k] = v
  end
end
return WingData
