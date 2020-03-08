local SImproveYuanShenRep = class("SImproveYuanShenRep")
SImproveYuanShenRep.TYPEID = 12588055
function SImproveYuanShenRep:ctor(partnerId, index)
  self.id = 12588055
  self.partnerId = partnerId or nil
  self.index = index or nil
end
function SImproveYuanShenRep:marshal(os)
  os:marshalInt32(self.partnerId)
  os:marshalInt32(self.index)
end
function SImproveYuanShenRep:unmarshal(os)
  self.partnerId = os:unmarshalInt32()
  self.index = os:unmarshalInt32()
end
function SImproveYuanShenRep:sizepolicy(size)
  return size <= 65535
end
return SImproveYuanShenRep
