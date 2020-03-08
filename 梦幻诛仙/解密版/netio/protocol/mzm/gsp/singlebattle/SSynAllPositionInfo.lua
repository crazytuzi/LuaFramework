local SSynAllPositionInfo = class("SSynAllPositionInfo")
SSynAllPositionInfo.TYPEID = 12621603
function SSynAllPositionInfo:ctor(positionInfos)
  self.id = 12621603
  self.positionInfos = positionInfos or {}
end
function SSynAllPositionInfo:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.positionInfos) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.positionInfos) do
    os:marshalInt64(k)
    v:marshal(os)
  end
end
function SSynAllPositionInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local BeanClazz = require("netio.protocol.mzm.gsp.singlebattle.RolePosition")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.positionInfos[k] = v
  end
end
function SSynAllPositionInfo:sizepolicy(size)
  return size <= 65535
end
return SSynAllPositionInfo
