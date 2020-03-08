local CJewelTransferReq = class("CJewelTransferReq")
CJewelTransferReq.TYPEID = 12618783
function CJewelTransferReq:ctor(fromJewelBagId, fromJewelGridNo, toJewelCfgId)
  self.id = 12618783
  self.fromJewelBagId = fromJewelBagId or nil
  self.fromJewelGridNo = fromJewelGridNo or nil
  self.toJewelCfgId = toJewelCfgId or nil
end
function CJewelTransferReq:marshal(os)
  os:marshalInt32(self.fromJewelBagId)
  os:marshalInt32(self.fromJewelGridNo)
  os:marshalInt32(self.toJewelCfgId)
end
function CJewelTransferReq:unmarshal(os)
  self.fromJewelBagId = os:unmarshalInt32()
  self.fromJewelGridNo = os:unmarshalInt32()
  self.toJewelCfgId = os:unmarshalInt32()
end
function CJewelTransferReq:sizepolicy(size)
  return size <= 65535
end
return CJewelTransferReq
