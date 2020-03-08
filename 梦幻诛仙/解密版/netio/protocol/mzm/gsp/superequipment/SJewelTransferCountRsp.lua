local SJewelTransferCountRsp = class("SJewelTransferCountRsp")
SJewelTransferCountRsp.TYPEID = 12618785
function SJewelTransferCountRsp:ctor(count)
  self.id = 12618785
  self.count = count or nil
end
function SJewelTransferCountRsp:marshal(os)
  os:marshalInt32(self.count)
end
function SJewelTransferCountRsp:unmarshal(os)
  self.count = os:unmarshalInt32()
end
function SJewelTransferCountRsp:sizepolicy(size)
  return size <= 65535
end
return SJewelTransferCountRsp
