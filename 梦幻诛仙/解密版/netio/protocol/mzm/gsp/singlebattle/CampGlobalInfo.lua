local OctetsStream = require("netio.OctetsStream")
local CampInfo = require("netio.protocol.mzm.gsp.singlebattle.CampInfo")
local CampGlobalInfo = class("CampGlobalInfo")
function CampGlobalInfo:ctor(campInfo, roleInfos)
  self.campInfo = campInfo or CampInfo.new()
  self.roleInfos = roleInfos or {}
end
function CampGlobalInfo:marshal(os)
  self.campInfo:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.roleInfos) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.roleInfos) do
    os:marshalInt64(k)
    v:marshal(os)
  end
end
function CampGlobalInfo:unmarshal(os)
  self.campInfo = CampInfo.new()
  self.campInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local BeanClazz = require("netio.protocol.mzm.gsp.singlebattle.RoleTotalInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.roleInfos[k] = v
  end
end
return CampGlobalInfo
