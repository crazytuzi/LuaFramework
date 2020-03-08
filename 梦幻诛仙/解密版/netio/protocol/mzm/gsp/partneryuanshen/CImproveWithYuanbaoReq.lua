local CImproveWithYuanbaoReq = class("CImproveWithYuanbaoReq")
CImproveWithYuanbaoReq.TYPEID = 12621057
function CImproveWithYuanbaoReq:ctor(position, current_yuanbao, property_num)
  self.id = 12621057
  self.position = position or nil
  self.current_yuanbao = current_yuanbao or nil
  self.property_num = property_num or nil
end
function CImproveWithYuanbaoReq:marshal(os)
  os:marshalInt32(self.position)
  os:marshalInt64(self.current_yuanbao)
  os:marshalInt32(self.property_num)
end
function CImproveWithYuanbaoReq:unmarshal(os)
  self.position = os:unmarshalInt32()
  self.current_yuanbao = os:unmarshalInt64()
  self.property_num = os:unmarshalInt32()
end
function CImproveWithYuanbaoReq:sizepolicy(size)
  return size <= 65535
end
return CImproveWithYuanbaoReq
