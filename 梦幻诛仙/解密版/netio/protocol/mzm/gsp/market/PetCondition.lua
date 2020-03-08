local OctetsStream = require("netio.OctetsStream")
local PetCondition = class("PetCondition")
function PetCondition:ctor(subid, qualitys, petTypes, skillNum, skillIds, custtime)
  self.subid = subid or nil
  self.qualitys = qualitys or {}
  self.petTypes = petTypes or {}
  self.skillNum = skillNum or nil
  self.skillIds = skillIds or {}
  self.custtime = custtime or nil
end
function PetCondition:marshal(os)
  os:marshalInt32(self.subid)
  do
    local _size_ = 0
    for _, _ in pairs(self.qualitys) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, _ in pairs(self.qualitys) do
      os:marshalInt32(k)
    end
  end
  do
    local _size_ = 0
    for _, _ in pairs(self.petTypes) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, _ in pairs(self.petTypes) do
      os:marshalInt32(k)
    end
  end
  os:marshalInt32(self.skillNum)
  do
    local _size_ = 0
    for _, _ in pairs(self.skillIds) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, _ in pairs(self.skillIds) do
      os:marshalInt32(k)
    end
  end
  os:marshalInt64(self.custtime)
end
function PetCondition:unmarshal(os)
  self.subid = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    self.qualitys[v] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    self.petTypes[v] = v
  end
  self.skillNum = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    self.skillIds[v] = v
  end
  self.custtime = os:unmarshalInt64()
end
return PetCondition
