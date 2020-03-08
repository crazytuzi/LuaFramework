local CAddLineUpPartnerReq = class("CAddLineUpPartnerReq")
CAddLineUpPartnerReq.TYPEID = 12588039
function CAddLineUpPartnerReq:ctor(lineUpNum, partnerId)
  self.id = 12588039
  self.lineUpNum = lineUpNum or nil
  self.partnerId = partnerId or nil
end
function CAddLineUpPartnerReq:marshal(os)
  os:marshalInt32(self.lineUpNum)
  os:marshalInt32(self.partnerId)
end
function CAddLineUpPartnerReq:unmarshal(os)
  self.lineUpNum = os:unmarshalInt32()
  self.partnerId = os:unmarshalInt32()
end
function CAddLineUpPartnerReq:sizepolicy(size)
  return size <= 65535
end
return CAddLineUpPartnerReq
