local SSyncPartnerRep = class("SSyncPartnerRep")
SSyncPartnerRep.TYPEID = 12588046
function SSyncPartnerRep:ctor(partnerId2property)
  self.id = 12588046
  self.partnerId2property = partnerId2property or {}
end
function SSyncPartnerRep:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.partnerId2property) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.partnerId2property) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function SSyncPartnerRep:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.partner.Property")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.partnerId2property[k] = v
  end
end
function SSyncPartnerRep:sizepolicy(size)
  return size <= 65535
end
return SSyncPartnerRep
