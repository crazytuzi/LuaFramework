local OctetsStream = require("netio.OctetsStream")
local GangHelpInfo = class("GangHelpInfo")
function GangHelpInfo:ctor(role2helpData)
  self.role2helpData = role2helpData or {}
end
function GangHelpInfo:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.role2helpData) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.role2helpData) do
    os:marshalInt64(k)
    v:marshal(os)
  end
end
function GangHelpInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local BeanClazz = require("netio.protocol.mzm.gsp.huanhun.CallHelpData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.role2helpData[k] = v
  end
end
return GangHelpInfo
