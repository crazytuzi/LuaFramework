local SJewelTransferRsp = class("SJewelTransferRsp")
SJewelTransferRsp.TYPEID = 12618786
function SJewelTransferRsp:ctor(fromJewelBagId, fromJewelGridNo, toJewelCfgId, availableTransferCount, moneyCount)
  self.id = 12618786
  self.fromJewelBagId = fromJewelBagId or nil
  self.fromJewelGridNo = fromJewelGridNo or nil
  self.toJewelCfgId = toJewelCfgId or nil
  self.availableTransferCount = availableTransferCount or nil
  self.moneyCount = moneyCount or nil
end
function SJewelTransferRsp:marshal(os)
  os:marshalInt32(self.fromJewelBagId)
  os:marshalInt32(self.fromJewelGridNo)
  os:marshalInt32(self.toJewelCfgId)
  os:marshalInt32(self.availableTransferCount)
  os:marshalInt32(self.moneyCount)
end
function SJewelTransferRsp:unmarshal(os)
  self.fromJewelBagId = os:unmarshalInt32()
  self.fromJewelGridNo = os:unmarshalInt32()
  self.toJewelCfgId = os:unmarshalInt32()
  self.availableTransferCount = os:unmarshalInt32()
  self.moneyCount = os:unmarshalInt32()
end
function SJewelTransferRsp:sizepolicy(size)
  return size <= 65535
end
return SJewelTransferRsp
