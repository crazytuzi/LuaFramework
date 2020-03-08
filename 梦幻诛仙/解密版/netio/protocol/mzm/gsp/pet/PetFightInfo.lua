local OctetsStream = require("netio.OctetsStream")
local PetFightSkillInfo = require("netio.protocol.mzm.gsp.pet.PetFightSkillInfo")
local PetFightInfo = class("PetFightInfo")
function PetFightInfo:ctor(defense_team, team_info, formation_info, skill_info)
  self.defense_team = defense_team or nil
  self.team_info = team_info or {}
  self.formation_info = formation_info or {}
  self.skill_info = skill_info or PetFightSkillInfo.new()
end
function PetFightInfo:marshal(os)
  os:marshalInt32(self.defense_team)
  do
    local _size_ = 0
    for _, _ in pairs(self.team_info) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.team_info) do
      os:marshalInt32(k)
      v:marshal(os)
    end
  end
  do
    local _size_ = 0
    for _, _ in pairs(self.formation_info) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.formation_info) do
      os:marshalInt32(k)
      v:marshal(os)
    end
  end
  self.skill_info:marshal(os)
end
function PetFightInfo:unmarshal(os)
  self.defense_team = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.pet.PetFightTeamInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.team_info[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.pet.PetFightFormationInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.formation_info[k] = v
  end
  self.skill_info = PetFightSkillInfo.new()
  self.skill_info:unmarshal(os)
end
return PetFightInfo
