local SSynMakeCakeStage = class("SSynMakeCakeStage")
SSynMakeCakeStage.TYPEID = 12627713
function SSynMakeCakeStage:ctor(activityInfos)
  self.id = 12627713
  self.activityInfos = activityInfos or {}
end
function SSynMakeCakeStage:marshal(os)
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
function SSynMakeCakeStage:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.cake.RoleCakeInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.activityInfos[k] = v
  end
end
function SSynMakeCakeStage:sizepolicy(size)
  return size <= 65535
end
return SSynMakeCakeStage
