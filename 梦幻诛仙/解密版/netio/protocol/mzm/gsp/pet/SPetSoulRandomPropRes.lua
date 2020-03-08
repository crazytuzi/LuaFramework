local SPetSoulRandomPropRes = class("SPetSoulRandomPropRes")
SPetSoulRandomPropRes.TYPEID = 12590670
function SPetSoulRandomPropRes:ctor(petId, pos, oldPropIndex, newPropIndex)
  self.id = 12590670
  self.petId = petId or nil
  self.pos = pos or nil
  self.oldPropIndex = oldPropIndex or nil
  self.newPropIndex = newPropIndex or nil
end
function SPetSoulRandomPropRes:marshal(os)
  os:marshalInt64(self.petId)
  os:marshalInt32(self.pos)
  os:marshalInt32(self.oldPropIndex)
  os:marshalInt32(self.newPropIndex)
end
function SPetSoulRandomPropRes:unmarshal(os)
  self.petId = os:unmarshalInt64()
  self.pos = os:unmarshalInt32()
  self.oldPropIndex = os:unmarshalInt32()
  self.newPropIndex = os:unmarshalInt32()
end
function SPetSoulRandomPropRes:sizepolicy(size)
  return size <= 65535
end
return SPetSoulRandomPropRes
