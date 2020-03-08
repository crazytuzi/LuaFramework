local OctetsStream = require("netio.OctetsStream")
local BanGraphData = class("BanGraphData")
function BanGraphData:ctor(graphIds)
  self.graphIds = graphIds or {}
end
function BanGraphData:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.graphIds) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, _ in pairs(self.graphIds) do
    os:marshalInt32(k)
  end
end
function BanGraphData:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    self.graphIds[v] = v
  end
end
return BanGraphData
