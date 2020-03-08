local OctetsStream = require("netio.OctetsStream")
local LongJingChangeInfo = class("LongJingChangeInfo")
function LongJingChangeInfo:ctor(changed, remPositions)
  self.changed = changed or {}
  self.remPositions = remPositions or {}
end
function LongJingChangeInfo:marshal(os)
  do
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
  local _size_ = 0
  for _, _ in pairs(self.remPositions) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, _ in pairs(self.remPositions) do
    os:marshalInt32(k)
  end
end
function LongJingChangeInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.item.ItemInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.changed[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    self.remPositions[v] = v
  end
end
return LongJingChangeInfo
