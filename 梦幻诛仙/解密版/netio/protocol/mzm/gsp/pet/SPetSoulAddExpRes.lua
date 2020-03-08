local SPetSoulAddExpRes = class("SPetSoulAddExpRes")
SPetSoulAddExpRes.TYPEID = 12590668
function SPetSoulAddExpRes:ctor(petId, pos, level, exp)
  self.id = 12590668
  self.petId = petId or nil
  self.pos = pos or nil
  self.level = level or nil
  self.exp = exp or nil
end
function SPetSoulAddExpRes:marshal(os)
  os:marshalInt64(self.petId)
  os:marshalInt32(self.pos)
  os:marshalInt32(self.level)
  os:marshalInt32(self.exp)
end
function SPetSoulAddExpRes:unmarshal(os)
  self.petId = os:unmarshalInt64()
  self.pos = os:unmarshalInt32()
  self.level = os:unmarshalInt32()
  self.exp = os:unmarshalInt32()
end
function SPetSoulAddExpRes:sizepolicy(size)
  return size <= 65535
end
return SPetSoulAddExpRes
