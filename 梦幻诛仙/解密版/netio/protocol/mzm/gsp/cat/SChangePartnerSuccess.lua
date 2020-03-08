local SChangePartnerSuccess = class("SChangePartnerSuccess")
SChangePartnerSuccess.TYPEID = 12605713
function SChangePartnerSuccess:ctor(partner_cfgid)
  self.id = 12605713
  self.partner_cfgid = partner_cfgid or nil
end
function SChangePartnerSuccess:marshal(os)
  os:marshalInt32(self.partner_cfgid)
end
function SChangePartnerSuccess:unmarshal(os)
  self.partner_cfgid = os:unmarshalInt32()
end
function SChangePartnerSuccess:sizepolicy(size)
  return size <= 65535
end
return SChangePartnerSuccess
