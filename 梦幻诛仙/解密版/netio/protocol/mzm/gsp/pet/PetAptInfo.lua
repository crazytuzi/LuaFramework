local OctetsStream = require("netio.OctetsStream")
local PetAptInfo = class("PetAptInfo")
function PetAptInfo:ctor(aptMap, aptLimitMap)
  self.aptMap = aptMap or {}
  self.aptLimitMap = aptLimitMap or {}
end
function PetAptInfo:marshal(os)
  do
    local _size_ = 0
    for _, _ in pairs(self.aptMap) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.aptMap) do
      os:marshalInt32(k)
      os:marshalInt32(v)
    end
  end
  local _size_ = 0
  for _, _ in pairs(self.aptLimitMap) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.aptLimitMap) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function PetAptInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.aptMap[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.aptLimitMap[k] = v
  end
end
return PetAptInfo
