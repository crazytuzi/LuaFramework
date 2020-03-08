local STransferStrengthFromOcpBagRes = class("STransferStrengthFromOcpBagRes")
STransferStrengthFromOcpBagRes.TYPEID = 12607752
function STransferStrengthFromOcpBagRes:ctor(ocp, key, itemId, strengthLevel)
  self.id = 12607752
  self.ocp = ocp or nil
  self.key = key or nil
  self.itemId = itemId or nil
  self.strengthLevel = strengthLevel or nil
end
function STransferStrengthFromOcpBagRes:marshal(os)
  os:marshalInt32(self.ocp)
  os:marshalInt32(self.key)
  os:marshalInt32(self.itemId)
  os:marshalInt32(self.strengthLevel)
end
function STransferStrengthFromOcpBagRes:unmarshal(os)
  self.ocp = os:unmarshalInt32()
  self.key = os:unmarshalInt32()
  self.itemId = os:unmarshalInt32()
  self.strengthLevel = os:unmarshalInt32()
end
function STransferStrengthFromOcpBagRes:sizepolicy(size)
  return size <= 65535
end
return STransferStrengthFromOcpBagRes
