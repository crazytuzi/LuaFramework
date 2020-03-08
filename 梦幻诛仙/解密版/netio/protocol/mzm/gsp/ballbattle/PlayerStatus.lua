local OctetsStream = require("netio.OctetsStream")
local PlayerStatus = class("PlayerStatus")
function PlayerStatus:ctor(level, gene, states)
  self.level = level or nil
  self.gene = gene or nil
  self.states = states or {}
end
function PlayerStatus:marshal(os)
  os:marshalInt32(self.level)
  os:marshalInt32(self.gene)
  local _size_ = 0
  for _, _ in pairs(self.states) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, _ in pairs(self.states) do
    os:marshalInt32(k)
  end
end
function PlayerStatus:unmarshal(os)
  self.level = os:unmarshalInt32()
  self.gene = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    self.states[v] = v
  end
end
return PlayerStatus
