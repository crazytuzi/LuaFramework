local OctetsStream = require("netio.OctetsStream")
local GeniusSeriesInfo = class("GeniusSeriesInfo")
function GeniusSeriesInfo:ctor(genius_skills)
  self.genius_skills = genius_skills or {}
end
function GeniusSeriesInfo:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.genius_skills) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.genius_skills) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function GeniusSeriesInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.genius_skills[k] = v
  end
end
return GeniusSeriesInfo
