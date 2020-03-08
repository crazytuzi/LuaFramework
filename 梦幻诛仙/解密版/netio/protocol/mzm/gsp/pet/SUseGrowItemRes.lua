local SUseGrowItemRes = class("SUseGrowItemRes")
SUseGrowItemRes.TYPEID = 12590596
function SUseGrowItemRes:ctor(addGrow, petId, growItemLeft)
  self.id = 12590596
  self.addGrow = addGrow or nil
  self.petId = petId or nil
  self.growItemLeft = growItemLeft or nil
end
function SUseGrowItemRes:marshal(os)
  os:marshalFloat(self.addGrow)
  os:marshalInt64(self.petId)
  os:marshalInt32(self.growItemLeft)
end
function SUseGrowItemRes:unmarshal(os)
  self.addGrow = os:unmarshalFloat()
  self.petId = os:unmarshalInt64()
  self.growItemLeft = os:unmarshalInt32()
end
function SUseGrowItemRes:sizepolicy(size)
  return size <= 65535
end
return SUseGrowItemRes
