local SFixEquipmentRes = class("SFixEquipmentRes")
SFixEquipmentRes.TYPEID = 12584705
function SFixEquipmentRes:ctor()
  self.id = 12584705
end
function SFixEquipmentRes:marshal(os)
end
function SFixEquipmentRes:unmarshal(os)
end
function SFixEquipmentRes:sizepolicy(size)
  return size <= 65535
end
return SFixEquipmentRes
