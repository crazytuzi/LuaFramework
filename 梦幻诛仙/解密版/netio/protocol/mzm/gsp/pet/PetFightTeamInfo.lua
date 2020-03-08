local OctetsStream = require("netio.OctetsStream")
local PetFightTeamInfo = class("PetFightTeamInfo")
function PetFightTeamInfo:ctor(position2pet, formation_id)
  self.position2pet = position2pet or {}
  self.formation_id = formation_id or nil
end
function PetFightTeamInfo:marshal(os)
  do
    local _size_ = 0
    for _, _ in pairs(self.position2pet) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.position2pet) do
      os:marshalInt32(k)
      os:marshalInt64(v)
    end
  end
  os:marshalInt32(self.formation_id)
end
function PetFightTeamInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt64()
    self.position2pet[k] = v
  end
  self.formation_id = os:unmarshalInt32()
end
return PetFightTeamInfo
