local OctetsStream = require("netio.OctetsStream")
local CostInfo = class("CostInfo")
function CostInfo:ctor(itemKey2Num)
  self.itemKey2Num = itemKey2Num or {}
end
function CostInfo:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.itemKey2Num) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.itemKey2Num) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function CostInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.itemKey2Num[k] = v
  end
end
return CostInfo
