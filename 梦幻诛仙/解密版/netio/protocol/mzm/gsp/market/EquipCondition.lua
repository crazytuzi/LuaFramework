local OctetsStream = require("netio.OctetsStream")
local EquipCondition = class("EquipCondition")
function EquipCondition:ctor(subid, level, colors, skillIds, custtime)
  self.subid = subid or nil
  self.level = level or nil
  self.colors = colors or {}
  self.skillIds = skillIds or {}
  self.custtime = custtime or nil
end
function EquipCondition:marshal(os)
  os:marshalInt32(self.subid)
  os:marshalInt32(self.level)
  do
    local _size_ = 0
    for _, _ in pairs(self.colors) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, _ in pairs(self.colors) do
      os:marshalInt32(k)
    end
  end
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
function EquipCondition:unmarshal(os)
  self.subid = os:unmarshalInt32()
  self.level = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    self.colors[v] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    self.skillIds[v] = v
  end
  self.custtime = os:unmarshalInt64()
end
return EquipCondition
