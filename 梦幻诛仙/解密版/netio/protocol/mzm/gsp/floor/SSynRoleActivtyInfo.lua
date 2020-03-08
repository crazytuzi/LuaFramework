local SSynRoleActivtyInfo = class("SSynRoleActivtyInfo")
SSynRoleActivtyInfo.TYPEID = 12617736
function SSynRoleActivtyInfo:ctor(activityInfos)
  self.id = 12617736
  self.activityInfos = activityInfos or {}
end
function SSynRoleActivtyInfo:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.activityInfos) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.activityInfos) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function SSynRoleActivtyInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.floor.RoleFloorActivityInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.activityInfos[k] = v
  end
end
function SSynRoleActivtyInfo:sizepolicy(size)
  return size <= 65535
end
return SSynRoleActivtyInfo
