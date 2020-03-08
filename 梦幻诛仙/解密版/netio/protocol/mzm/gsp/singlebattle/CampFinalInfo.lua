local OctetsStream = require("netio.OctetsStream")
local CampFinalInfo = class("CampFinalInfo")
function CampFinalInfo:ctor(totalSource, roleFinalInfos)
  self.totalSource = totalSource or nil
  self.roleFinalInfos = roleFinalInfos or {}
end
function CampFinalInfo:marshal(os)
  os:marshalInt32(self.totalSource)
  local _size_ = 0
  for _, _ in pairs(self.roleFinalInfos) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.roleFinalInfos) do
    os:marshalInt64(k)
    v:marshal(os)
  end
end
function CampFinalInfo:unmarshal(os)
  self.totalSource = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local BeanClazz = require("netio.protocol.mzm.gsp.singlebattle.RoleFinalInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.roleFinalInfos[k] = v
  end
end
return CampFinalInfo
