local OctetsStream = require("netio.OctetsStream")
local FaBaoChangeInfo = class("FaBaoChangeInfo")
function FaBaoChangeInfo:ctor(removed, changed)
  self.removed = removed or {}
  self.changed = changed or {}
end
function FaBaoChangeInfo:marshal(os)
  do
    local _size_ = 0
    for _, _ in pairs(self.removed) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, _ in pairs(self.removed) do
      os:marshalInt32(k)
    end
  end
  local _size_ = 0
  for _, _ in pairs(self.changed) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.changed) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function FaBaoChangeInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    self.removed[v] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.item.ItemInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.changed[k] = v
  end
end
return FaBaoChangeInfo
