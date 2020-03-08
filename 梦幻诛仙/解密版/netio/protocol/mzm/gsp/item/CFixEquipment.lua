local CFixEquipment = class("CFixEquipment")
CFixEquipment.TYPEID = 12584748
function CFixEquipment:ctor(desEquipBagid, desEquipKey)
  self.id = 12584748
  self.desEquipBagid = desEquipBagid or nil
  self.desEquipKey = desEquipKey or nil
end
function CFixEquipment:marshal(os)
  os:marshalInt32(self.desEquipBagid)
  os:marshalInt32(self.desEquipKey)
end
function CFixEquipment:unmarshal(os)
  self.desEquipBagid = os:unmarshalInt32()
  self.desEquipKey = os:unmarshalInt32()
end
function CFixEquipment:sizepolicy(size)
  return size <= 65535
end
return CFixEquipment
