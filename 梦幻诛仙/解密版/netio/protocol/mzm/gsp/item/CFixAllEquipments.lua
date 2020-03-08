local CFixAllEquipments = class("CFixAllEquipments")
CFixAllEquipments.TYPEID = 12584713
function CFixAllEquipments:ctor()
  self.id = 12584713
end
function CFixAllEquipments:marshal(os)
end
function CFixAllEquipments:unmarshal(os)
end
function CFixAllEquipments:sizepolicy(size)
  return size <= 65535
end
return CFixAllEquipments
