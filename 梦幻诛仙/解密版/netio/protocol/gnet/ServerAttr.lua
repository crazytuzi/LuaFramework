local OctetsStream = require("netio.OctetsStream")
local ServerAttr = class("ServerAttr")
ServerAttr.FLAG_DOUBLE_DROP = 4
ServerAttr.FLAG_DOUBLE_SP = 8
function ServerAttr:ctor(flags, load, extra)
  self.flags = flags or nil
  self.load = load or nil
  self.extra = extra or {}
end
function ServerAttr:marshal(os)
  os:marshalInt32(self.flags)
  os:marshalUInt8(self.load)
  local _size_ = 0
  for _, _ in pairs(self.extra) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.extra) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function ServerAttr:unmarshal(os)
  self.flags = os:unmarshalInt32()
  self.load = os:unmarshalUInt8()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.extra[k] = v
  end
end
return ServerAttr
