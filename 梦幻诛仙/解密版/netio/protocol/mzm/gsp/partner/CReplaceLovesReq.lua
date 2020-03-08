local CReplaceLovesReq = class("CReplaceLovesReq")
CReplaceLovesReq.TYPEID = 12588050
function CReplaceLovesReq:ctor(partnerId)
  self.id = 12588050
  self.partnerId = partnerId or nil
end
function CReplaceLovesReq:marshal(os)
  os:marshalInt32(self.partnerId)
end
function CReplaceLovesReq:unmarshal(os)
  self.partnerId = os:unmarshalInt32()
end
function CReplaceLovesReq:sizepolicy(size)
  return size <= 65535
end
return CReplaceLovesReq
