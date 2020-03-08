local OctetsStream = require("netio.OctetsStream")
local FabaoArtifactInfo = class("FabaoArtifactInfo")
function FabaoArtifactInfo:ctor(expire_time, level, upgrade_exp, properties)
  self.expire_time = expire_time or nil
  self.level = level or nil
  self.upgrade_exp = upgrade_exp or nil
  self.properties = properties or {}
end
function FabaoArtifactInfo:marshal(os)
  os:marshalInt32(self.expire_time)
  os:marshalInt32(self.level)
  os:marshalInt32(self.upgrade_exp)
  local _size_ = 0
  for _, _ in pairs(self.properties) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.properties) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function FabaoArtifactInfo:unmarshal(os)
  self.expire_time = os:unmarshalInt32()
  self.level = os:unmarshalInt32()
  self.upgrade_exp = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.properties[k] = v
  end
end
return FabaoArtifactInfo
