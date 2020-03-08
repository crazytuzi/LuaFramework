local SAutoBreedBabyRes = class("SAutoBreedBabyRes")
SAutoBreedBabyRes.TYPEID = 12609438
function SAutoBreedBabyRes:ctor(childid)
  self.id = 12609438
  self.childid = childid or nil
end
function SAutoBreedBabyRes:marshal(os)
  os:marshalInt64(self.childid)
end
function SAutoBreedBabyRes:unmarshal(os)
  self.childid = os:unmarshalInt64()
end
function SAutoBreedBabyRes:sizepolicy(size)
  return size <= 65535
end
return SAutoBreedBabyRes
