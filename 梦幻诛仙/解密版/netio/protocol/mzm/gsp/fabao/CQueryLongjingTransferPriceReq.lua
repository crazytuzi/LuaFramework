local CQueryLongjingTransferPriceReq = class("CQueryLongjingTransferPriceReq")
CQueryLongjingTransferPriceReq.TYPEID = 12596040
function CQueryLongjingTransferPriceReq:ctor(srcitemid, targetitemid)
  self.id = 12596040
  self.srcitemid = srcitemid or nil
  self.targetitemid = targetitemid or nil
end
function CQueryLongjingTransferPriceReq:marshal(os)
  os:marshalInt32(self.srcitemid)
  os:marshalInt32(self.targetitemid)
end
function CQueryLongjingTransferPriceReq:unmarshal(os)
  self.srcitemid = os:unmarshalInt32()
  self.targetitemid = os:unmarshalInt32()
end
function CQueryLongjingTransferPriceReq:sizepolicy(size)
  return size <= 65535
end
return CQueryLongjingTransferPriceReq
