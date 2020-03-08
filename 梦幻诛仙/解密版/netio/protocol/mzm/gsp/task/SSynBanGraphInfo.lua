local SSynBanGraphInfo = class("SSynBanGraphInfo")
SSynBanGraphInfo.TYPEID = 12592152
function SSynBanGraphInfo:ctor(allBanGraphIds)
  self.id = 12592152
  self.allBanGraphIds = allBanGraphIds or {}
end
function SSynBanGraphInfo:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.allBanGraphIds) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.allBanGraphIds) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function SSynBanGraphInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.task.BanGraphData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.allBanGraphIds[k] = v
  end
end
function SSynBanGraphInfo:sizepolicy(size)
  return size <= 65535
end
return SSynBanGraphInfo
