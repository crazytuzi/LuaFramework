local OctetsStream = require("netio.OctetsStream")
local BuffInfo = class("BuffInfo")
BuffInfo.RATE = 0
BuffInfo.TIME = 1
function BuffInfo:ctor(buffId, typeValue, idipBuffInfo)
  self.buffId = buffId or nil
  self.typeValue = typeValue or nil
  self.idipBuffInfo = idipBuffInfo or {}
end
function BuffInfo:marshal(os)
  os:marshalInt32(self.buffId)
  os:marshalInt64(self.typeValue)
  local _size_ = 0
  for _, _ in pairs(self.idipBuffInfo) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.idipBuffInfo) do
    os:marshalInt32(k)
    os:marshalInt64(v)
  end
end
function BuffInfo:unmarshal(os)
  self.buffId = os:unmarshalInt32()
  self.typeValue = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt64()
    self.idipBuffInfo[k] = v
  end
end
return BuffInfo
