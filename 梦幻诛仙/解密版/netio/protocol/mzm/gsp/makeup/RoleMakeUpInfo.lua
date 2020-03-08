local OctetsStream = require("netio.OctetsStream")
local RoleMakeUpInfo = class("RoleMakeUpInfo")
function RoleMakeUpInfo:ctor(record)
  self.record = record or {}
end
function RoleMakeUpInfo:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.record) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.record) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function RoleMakeUpInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.record[k] = v
  end
end
return RoleMakeUpInfo
