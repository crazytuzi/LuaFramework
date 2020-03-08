local CAttachPartnerReq = class("CAttachPartnerReq")
CAttachPartnerReq.TYPEID = 12621062
function CAttachPartnerReq:ctor(position, partner_id)
  self.id = 12621062
  self.position = position or nil
  self.partner_id = partner_id or nil
end
function CAttachPartnerReq:marshal(os)
  os:marshalInt32(self.position)
  os:marshalInt32(self.partner_id)
end
function CAttachPartnerReq:unmarshal(os)
  self.position = os:unmarshalInt32()
  self.partner_id = os:unmarshalInt32()
end
function CAttachPartnerReq:sizepolicy(size)
  return size <= 65535
end
return CAttachPartnerReq
