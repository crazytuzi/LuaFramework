local SSynTotalPositionInfo = class("SSynTotalPositionInfo")
SSynTotalPositionInfo.TYPEID = 12621585
function SSynTotalPositionInfo:ctor(positionInfos, roleGrabInfo)
  self.id = 12621585
  self.positionInfos = positionInfos or {}
  self.roleGrabInfo = roleGrabInfo or {}
end
function SSynTotalPositionInfo:marshal(os)
  do
    local _size_ = 0
    for _, _ in pairs(self.positionInfos) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.positionInfos) do
      os:marshalInt32(k)
      v:marshal(os)
    end
  end
  local _size_ = 0
  for _, _ in pairs(self.roleGrabInfo) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.roleGrabInfo) do
    os:marshalInt64(k)
    v:marshal(os)
  end
end
function SSynTotalPositionInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.singlebattle.PositionData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.positionInfos[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local BeanClazz = require("netio.protocol.mzm.gsp.singlebattle.RoleGrabPositionData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.roleGrabInfo[k] = v
  end
end
function SSynTotalPositionInfo:sizepolicy(size)
  return size <= 65535
end
return SSynTotalPositionInfo
