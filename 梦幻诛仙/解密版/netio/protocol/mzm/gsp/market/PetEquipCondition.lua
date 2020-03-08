local OctetsStream = require("netio.OctetsStream")
local PetEquipCondition = class("PetEquipCondition")
function PetEquipCondition:ctor(subid, property, skillIds, custtime)
  self.subid = subid or nil
  self.property = property or nil
  self.skillIds = skillIds or {}
  self.custtime = custtime or nil
end
function PetEquipCondition:marshal(os)
  os:marshalInt32(self.subid)
  os:marshalInt32(self.property)
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
function PetEquipCondition:unmarshal(os)
  self.subid = os:unmarshalInt32()
  self.property = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    self.skillIds[v] = v
  end
  self.custtime = os:unmarshalInt64()
end
return PetEquipCondition
