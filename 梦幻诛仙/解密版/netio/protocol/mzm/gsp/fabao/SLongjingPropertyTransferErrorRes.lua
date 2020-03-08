local SLongjingPropertyTransferErrorRes = class("SLongjingPropertyTransferErrorRes")
SLongjingPropertyTransferErrorRes.TYPEID = 12596036
SLongjingPropertyTransferErrorRes.ERROR_UNKNOWN = 0
SLongjingPropertyTransferErrorRes.ERROR_COUNT_ERROR = 1
SLongjingPropertyTransferErrorRes.ERROR_ITEMID_NOT_EXSIT = 2
SLongjingPropertyTransferErrorRes.ERROR_PROPERTY_NOT_EXSIT = 3
SLongjingPropertyTransferErrorRes.ERROR_GOLD_TO_MAX = 4
SLongjingPropertyTransferErrorRes.ERROR_GOLD_NOT_ENOUGH = 5
SLongjingPropertyTransferErrorRes.ERROR_LEVEL_NOT_SAME = 6
function SLongjingPropertyTransferErrorRes:ctor(resultcode)
  self.id = 12596036
  self.resultcode = resultcode or nil
end
function SLongjingPropertyTransferErrorRes:marshal(os)
  os:marshalInt32(self.resultcode)
end
function SLongjingPropertyTransferErrorRes:unmarshal(os)
  self.resultcode = os:unmarshalInt32()
end
function SLongjingPropertyTransferErrorRes:sizepolicy(size)
  return size <= 65535
end
return SLongjingPropertyTransferErrorRes
