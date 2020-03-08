local Property = require("netio.protocol.mzm.gsp.partner.Property")
local SSyncSinglePartnerPro = class("SSyncSinglePartnerPro")
SSyncSinglePartnerPro.TYPEID = 12588058
function SSyncSinglePartnerPro:ctor(partnerId, property)
  self.id = 12588058
  self.partnerId = partnerId or nil
  self.property = property or Property.new()
end
function SSyncSinglePartnerPro:marshal(os)
  os:marshalInt32(self.partnerId)
  self.property:marshal(os)
end
function SSyncSinglePartnerPro:unmarshal(os)
  self.partnerId = os:unmarshalInt32()
  self.property = Property.new()
  self.property:unmarshal(os)
end
function SSyncSinglePartnerPro:sizepolicy(size)
  return size <= 65535
end
return SSyncSinglePartnerPro
