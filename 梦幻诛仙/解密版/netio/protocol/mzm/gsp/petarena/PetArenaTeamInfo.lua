local OctetsStream = require("netio.OctetsStream")
local PetArenaTeamInfo = class("PetArenaTeamInfo")
function PetArenaTeamInfo:ctor(formation, formation_level, position_infos, pet_infos, robot_infos)
  self.formation = formation or nil
  self.formation_level = formation_level or nil
  self.position_infos = position_infos or {}
  self.pet_infos = pet_infos or {}
  self.robot_infos = robot_infos or {}
end
function PetArenaTeamInfo:marshal(os)
  os:marshalInt32(self.formation)
  os:marshalInt32(self.formation_level)
  do
    local _size_ = 0
    for _, _ in pairs(self.position_infos) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.position_infos) do
      os:marshalInt32(k)
      v:marshal(os)
    end
  end
  do
    local _size_ = 0
    for _, _ in pairs(self.pet_infos) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.pet_infos) do
      os:marshalInt64(k)
      v:marshal(os)
    end
  end
  local _size_ = 0
  for _, _ in pairs(self.robot_infos) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.robot_infos) do
    os:marshalInt64(k)
    v:marshal(os)
  end
end
function PetArenaTeamInfo:unmarshal(os)
  self.formation = os:unmarshalInt32()
  self.formation_level = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.petarena.PositionInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.position_infos[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local BeanClazz = require("netio.protocol.mzm.gsp.pet.PetInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.pet_infos[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local BeanClazz = require("netio.protocol.mzm.gsp.petarena.RobotPetInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.robot_infos[k] = v
  end
end
return PetArenaTeamInfo
