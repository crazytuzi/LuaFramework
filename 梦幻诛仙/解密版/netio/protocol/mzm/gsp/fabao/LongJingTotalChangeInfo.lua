local OctetsStream = require("netio.OctetsStream")
local LongJingTotalChangeInfo = class("LongJingTotalChangeInfo")
function LongJingTotalChangeInfo:ctor(changed)
  self.changed = changed or {}
end
function LongJingTotalChangeInfo:marshal(os)
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
function LongJingTotalChangeInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.fabao.LongJingChangeInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.changed[k] = v
  end
end
return LongJingTotalChangeInfo
