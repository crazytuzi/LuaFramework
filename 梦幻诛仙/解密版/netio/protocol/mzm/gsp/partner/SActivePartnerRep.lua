local Property = require("netio.protocol.mzm.gsp.partner.Property")
local SActivePartnerRep = class("SActivePartnerRep")
SActivePartnerRep.TYPEID = 12588037
function SActivePartnerRep:ctor(partnerId, property)
  self.id = 12588037
  self.partnerId = partnerId or nil
  self.property = property or Property.new()
end
function SActivePartnerRep:marshal(os)
  os:marshalInt32(self.partnerId)
  self.property:marshal(os)
end
function SActivePartnerRep:unmarshal(os)
  self.partnerId = os:unmarshalInt32()
  self.property = Property.new()
  self.property:unmarshal(os)
end
function SActivePartnerRep:sizepolicy(size)
  return size <= 65535
end
return SActivePartnerRep
