local OctetsStream = require("netio.OctetsStream")
local AwardInfo = class("AwardInfo")
function AwardInfo:ctor(itemMap)
  self.itemMap = itemMap or {}
end
function AwardInfo:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.itemMap) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.itemMap) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function AwardInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.itemMap[k] = v
  end
end
return AwardInfo
