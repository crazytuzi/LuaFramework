local SPetSoulExchangeRes = class("SPetSoulExchangeRes")
SPetSoulExchangeRes.TYPEID = 12590666
function SPetSoulExchangeRes:ctor(petId1, petId2)
  self.id = 12590666
  self.petId1 = petId1 or nil
  self.petId2 = petId2 or nil
end
function SPetSoulExchangeRes:marshal(os)
  os:marshalInt64(self.petId1)
  os:marshalInt64(self.petId2)
end
function SPetSoulExchangeRes:unmarshal(os)
  self.petId1 = os:unmarshalInt64()
  self.petId2 = os:unmarshalInt64()
end
function SPetSoulExchangeRes:sizepolicy(size)
  return size <= 65535
end
return SPetSoulExchangeRes
