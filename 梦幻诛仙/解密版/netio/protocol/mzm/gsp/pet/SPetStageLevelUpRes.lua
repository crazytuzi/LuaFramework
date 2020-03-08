local SPetStageLevelUpRes = class("SPetStageLevelUpRes")
SPetStageLevelUpRes.TYPEID = 12590661
function SPetStageLevelUpRes:ctor(petId)
  self.id = 12590661
  self.petId = petId or nil
end
function SPetStageLevelUpRes:marshal(os)
  os:marshalInt64(self.petId)
end
function SPetStageLevelUpRes:unmarshal(os)
  self.petId = os:unmarshalInt64()
end
function SPetStageLevelUpRes:sizepolicy(size)
  return size <= 65535
end
return SPetStageLevelUpRes
