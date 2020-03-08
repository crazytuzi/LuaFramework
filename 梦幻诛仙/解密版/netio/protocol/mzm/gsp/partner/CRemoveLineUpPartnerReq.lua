local CRemoveLineUpPartnerReq = class("CRemoveLineUpPartnerReq")
CRemoveLineUpPartnerReq.TYPEID = 12588045
function CRemoveLineUpPartnerReq:ctor(lineUpNum, partnerId)
  self.id = 12588045
  self.lineUpNum = lineUpNum or nil
  self.partnerId = partnerId or nil
end
function CRemoveLineUpPartnerReq:marshal(os)
  os:marshalInt32(self.lineUpNum)
  os:marshalInt32(self.partnerId)
end
function CRemoveLineUpPartnerReq:unmarshal(os)
  self.lineUpNum = os:unmarshalInt32()
  self.partnerId = os:unmarshalInt32()
end
function CRemoveLineUpPartnerReq:sizepolicy(size)
  return size <= 65535
end
return CRemoveLineUpPartnerReq
