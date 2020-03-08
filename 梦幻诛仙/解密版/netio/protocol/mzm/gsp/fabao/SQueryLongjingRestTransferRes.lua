local SQueryLongjingRestTransferRes = class("SQueryLongjingRestTransferRes")
SQueryLongjingRestTransferRes.TYPEID = 12596035
function SQueryLongjingRestTransferRes:ctor(resttransfercount)
  self.id = 12596035
  self.resttransfercount = resttransfercount or nil
end
function SQueryLongjingRestTransferRes:marshal(os)
  os:marshalInt32(self.resttransfercount)
end
function SQueryLongjingRestTransferRes:unmarshal(os)
  self.resttransfercount = os:unmarshalInt32()
end
function SQueryLongjingRestTransferRes:sizepolicy(size)
  return size <= 65535
end
return SQueryLongjingRestTransferRes
