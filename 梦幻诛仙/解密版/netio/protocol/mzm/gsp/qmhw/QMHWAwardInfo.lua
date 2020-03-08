local OctetsStream = require("netio.OctetsStream")
local QMHWAwardInfo = class("QMHWAwardInfo")
function QMHWAwardInfo:ctor(winAwards, joinAwards)
  self.winAwards = winAwards or {}
  self.joinAwards = joinAwards or {}
end
function QMHWAwardInfo:marshal(os)
  do
    local _size_ = 0
    for _, _ in pairs(self.winAwards) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, _ in pairs(self.winAwards) do
      os:marshalInt32(k)
    end
  end
  local _size_ = 0
  for _, _ in pairs(self.joinAwards) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, _ in pairs(self.joinAwards) do
    os:marshalInt32(k)
  end
end
function QMHWAwardInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    self.winAwards[v] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    self.joinAwards[v] = v
  end
end
return QMHWAwardInfo
