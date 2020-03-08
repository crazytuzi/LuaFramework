local SExpandPetDepotRes = class("SExpandPetDepotRes")
SExpandPetDepotRes.TYPEID = 12590621
function SExpandPetDepotRes:ctor(depotSize)
  self.id = 12590621
  self.depotSize = depotSize or nil
end
function SExpandPetDepotRes:marshal(os)
  os:marshalInt32(self.depotSize)
end
function SExpandPetDepotRes:unmarshal(os)
  self.depotSize = os:unmarshalInt32()
end
function SExpandPetDepotRes:sizepolicy(size)
  return size <= 65535
end
return SExpandPetDepotRes
