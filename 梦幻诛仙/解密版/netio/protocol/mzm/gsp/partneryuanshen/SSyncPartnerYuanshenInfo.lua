local SSyncPartnerYuanshenInfo = class("SSyncPartnerYuanshenInfo")
SSyncPartnerYuanshenInfo.TYPEID = 12621063
function SSyncPartnerYuanshenInfo:ctor(position_info_map)
  self.id = 12621063
  self.position_info_map = position_info_map or {}
end
function SSyncPartnerYuanshenInfo:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.position_info_map) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.position_info_map) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function SSyncPartnerYuanshenInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.partneryuanshen.PartnerYuanshenPositionInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.position_info_map[k] = v
  end
end
function SSyncPartnerYuanshenInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncPartnerYuanshenInfo
