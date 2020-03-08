local CEquipTransferHun = class("CEquipTransferHun")
CEquipTransferHun.TYPEID = 12584716
function CEquipTransferHun:ctor(srceEquipKey, desEquipBagid, desEquipKey)
  self.id = 12584716
  self.srceEquipKey = srceEquipKey or nil
  self.desEquipBagid = desEquipBagid or nil
  self.desEquipKey = desEquipKey or nil
end
function CEquipTransferHun:marshal(os)
  os:marshalInt32(self.srceEquipKey)
  os:marshalInt32(self.desEquipBagid)
  os:marshalInt32(self.desEquipKey)
end
function CEquipTransferHun:unmarshal(os)
  self.srceEquipKey = os:unmarshalInt32()
  self.desEquipBagid = os:unmarshalInt32()
  self.desEquipKey = os:unmarshalInt32()
end
function CEquipTransferHun:sizepolicy(size)
  return size <= 65535
end
return CEquipTransferHun
