local CImproveYuanReq = class("CImproveYuanReq")
CImproveYuanReq.TYPEID = 12588057
function CImproveYuanReq:ctor(partnerId, index, toLevel)
  self.id = 12588057
  self.partnerId = partnerId or nil
  self.index = index or nil
  self.toLevel = toLevel or nil
end
function CImproveYuanReq:marshal(os)
  os:marshalInt32(self.partnerId)
  os:marshalInt32(self.index)
  os:marshalInt32(self.toLevel)
end
function CImproveYuanReq:unmarshal(os)
  self.partnerId = os:unmarshalInt32()
  self.index = os:unmarshalInt32()
  self.toLevel = os:unmarshalInt32()
end
function CImproveYuanReq:sizepolicy(size)
  return size <= 65535
end
return CImproveYuanReq
