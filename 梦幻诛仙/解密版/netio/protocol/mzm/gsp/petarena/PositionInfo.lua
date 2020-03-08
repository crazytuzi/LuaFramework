local OctetsStream = require("netio.OctetsStream")
local PositionInfo = class("PositionInfo")
function PositionInfo:ctor(petid, pet_fight_skill, properties)
  self.petid = petid or nil
  self.pet_fight_skill = pet_fight_skill or nil
  self.properties = properties or {}
end
function PositionInfo:marshal(os)
  os:marshalInt64(self.petid)
  os:marshalInt32(self.pet_fight_skill)
  local _size_ = 0
  for _, _ in pairs(self.properties) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.properties) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function PositionInfo:unmarshal(os)
  self.petid = os:unmarshalInt64()
  self.pet_fight_skill = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.properties[k] = v
  end
end
return PositionInfo
