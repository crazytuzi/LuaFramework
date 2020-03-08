local OctetsStream = require("netio.OctetsStream")
local FurnitureUuIds = class("FurnitureUuIds")
function FurnitureUuIds:ctor(uuids)
  self.uuids = uuids or {}
end
function FurnitureUuIds:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.uuids) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, _ in pairs(self.uuids) do
    os:marshalInt64(k)
  end
end
function FurnitureUuIds:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    self.uuids[v] = v
  end
end
return FurnitureUuIds
