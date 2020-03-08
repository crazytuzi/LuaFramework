local SAttachPartnerSuccess = class("SAttachPartnerSuccess")
SAttachPartnerSuccess.TYPEID = 12621058
function SAttachPartnerSuccess:ctor(position, partner_id)
  self.id = 12621058
  self.position = position or nil
  self.partner_id = partner_id or nil
end
function SAttachPartnerSuccess:marshal(os)
  os:marshalInt32(self.position)
  os:marshalInt32(self.partner_id)
end
function SAttachPartnerSuccess:unmarshal(os)
  self.position = os:unmarshalInt32()
  self.partner_id = os:unmarshalInt32()
end
function SAttachPartnerSuccess:sizepolicy(size)
  return size <= 65535
end
return SAttachPartnerSuccess
