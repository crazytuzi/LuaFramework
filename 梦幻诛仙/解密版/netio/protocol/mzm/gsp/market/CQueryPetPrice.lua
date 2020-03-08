local CQueryPetPrice = class("CQueryPetPrice")
CQueryPetPrice.TYPEID = 12601401
function CQueryPetPrice:ctor(petCfgId)
  self.id = 12601401
  self.petCfgId = petCfgId or nil
end
function CQueryPetPrice:marshal(os)
  os:marshalInt32(self.petCfgId)
end
function CQueryPetPrice:unmarshal(os)
  self.petCfgId = os:unmarshalInt32()
end
function CQueryPetPrice:sizepolicy(size)
  return size <= 65535
end
return CQueryPetPrice
