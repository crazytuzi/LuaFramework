local SUseExpItemRes = class("SUseExpItemRes")
SUseExpItemRes.TYPEID = 12590612
function SUseExpItemRes:ctor(addExp, petId)
  self.id = 12590612
  self.addExp = addExp or nil
  self.petId = petId or nil
end
function SUseExpItemRes:marshal(os)
  os:marshalInt32(self.addExp)
  os:marshalInt64(self.petId)
end
function SUseExpItemRes:unmarshal(os)
  self.addExp = os:unmarshalInt32()
  self.petId = os:unmarshalInt64()
end
function SUseExpItemRes:sizepolicy(size)
  return size <= 65535
end
return SUseExpItemRes
