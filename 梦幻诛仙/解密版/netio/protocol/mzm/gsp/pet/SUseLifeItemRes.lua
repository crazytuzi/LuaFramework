local SUseLifeItemRes = class("SUseLifeItemRes")
SUseLifeItemRes.TYPEID = 12590642
function SUseLifeItemRes:ctor(addLife, petId)
  self.id = 12590642
  self.addLife = addLife or nil
  self.petId = petId or nil
end
function SUseLifeItemRes:marshal(os)
  os:marshalInt32(self.addLife)
  os:marshalInt64(self.petId)
end
function SUseLifeItemRes:unmarshal(os)
  self.addLife = os:unmarshalInt32()
  self.petId = os:unmarshalInt64()
end
function SUseLifeItemRes:sizepolicy(size)
  return size <= 65535
end
return SUseLifeItemRes
