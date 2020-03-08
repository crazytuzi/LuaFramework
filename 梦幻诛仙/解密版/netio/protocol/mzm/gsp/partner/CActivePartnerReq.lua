local CActivePartnerReq = class("CActivePartnerReq")
CActivePartnerReq.TYPEID = 12588047
function CActivePartnerReq:ctor(partnerId)
  self.id = 12588047
  self.partnerId = partnerId or nil
end
function CActivePartnerReq:marshal(os)
  os:marshalInt32(self.partnerId)
end
function CActivePartnerReq:unmarshal(os)
  self.partnerId = os:unmarshalInt32()
end
function CActivePartnerReq:sizepolicy(size)
  return size <= 65535
end
return CActivePartnerReq
