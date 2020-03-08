local CPetSoulAddExpReq = class("CPetSoulAddExpReq")
CPetSoulAddExpReq.TYPEID = 12590669
function CPetSoulAddExpReq:ctor(petId, pos, itemId, isUseALl)
  self.id = 12590669
  self.petId = petId or nil
  self.pos = pos or nil
  self.itemId = itemId or nil
  self.isUseALl = isUseALl or nil
end
function CPetSoulAddExpReq:marshal(os)
  os:marshalInt64(self.petId)
  os:marshalInt32(self.pos)
  os:marshalInt32(self.itemId)
  os:marshalInt32(self.isUseALl)
end
function CPetSoulAddExpReq:unmarshal(os)
  self.petId = os:unmarshalInt64()
  self.pos = os:unmarshalInt32()
  self.itemId = os:unmarshalInt32()
  self.isUseALl = os:unmarshalInt32()
end
function CPetSoulAddExpReq:sizepolicy(size)
  return size <= 65535
end
return CPetSoulAddExpReq
