local CImproveWithItemReq = class("CImproveWithItemReq")
CImproveWithItemReq.TYPEID = 12621060
function CImproveWithItemReq:ctor(position, property_num)
  self.id = 12621060
  self.position = position or nil
  self.property_num = property_num or nil
end
function CImproveWithItemReq:marshal(os)
  os:marshalInt32(self.position)
  os:marshalInt32(self.property_num)
end
function CImproveWithItemReq:unmarshal(os)
  self.position = os:unmarshalInt32()
  self.property_num = os:unmarshalInt32()
end
function CImproveWithItemReq:sizepolicy(size)
  return size <= 65535
end
return CImproveWithItemReq
