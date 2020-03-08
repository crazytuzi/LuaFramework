local OctetsStream = require("netio.OctetsStream")
local BreakEggInfo = class("BreakEggInfo")
function BreakEggInfo:ctor(role_id, role_name, itemId2num)
  self.role_id = role_id or nil
  self.role_name = role_name or nil
  self.itemId2num = itemId2num or {}
end
function BreakEggInfo:marshal(os)
  os:marshalInt64(self.role_id)
  os:marshalString(self.role_name)
  local _size_ = 0
  for _, _ in pairs(self.itemId2num) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.itemId2num) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function BreakEggInfo:unmarshal(os)
  self.role_id = os:unmarshalInt64()
  self.role_name = os:unmarshalString()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.itemId2num[k] = v
  end
end
return BreakEggInfo
