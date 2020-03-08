local SPetSoulInitPropRes = class("SPetSoulInitPropRes")
SPetSoulInitPropRes.TYPEID = 12590673
function SPetSoulInitPropRes:ctor(petId, pos, propIndex)
  self.id = 12590673
  self.petId = petId or nil
  self.pos = pos or nil
  self.propIndex = propIndex or nil
end
function SPetSoulInitPropRes:marshal(os)
  os:marshalInt64(self.petId)
  os:marshalInt32(self.pos)
  os:marshalInt32(self.propIndex)
end
function SPetSoulInitPropRes:unmarshal(os)
  self.petId = os:unmarshalInt64()
  self.pos = os:unmarshalInt32()
  self.propIndex = os:unmarshalInt32()
end
function SPetSoulInitPropRes:sizepolicy(size)
  return size <= 65535
end
return SPetSoulInitPropRes
