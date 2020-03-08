local OctetsStream = require("netio.OctetsStream")
local AwardAddBean = class("AwardAddBean")
function AwardAddBean:ctor(addValues)
  self.addValues = addValues or {}
end
function AwardAddBean:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.addValues) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.addValues) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function AwardAddBean:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.addValues[k] = v
  end
end
return AwardAddBean
