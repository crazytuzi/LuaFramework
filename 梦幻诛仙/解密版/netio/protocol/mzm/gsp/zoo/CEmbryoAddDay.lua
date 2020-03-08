local CEmbryoAddDay = class("CEmbryoAddDay")
CEmbryoAddDay.TYPEID = 12615427
function CEmbryoAddDay:ctor(animalid)
  self.id = 12615427
  self.animalid = animalid or nil
end
function CEmbryoAddDay:marshal(os)
  os:marshalInt64(self.animalid)
end
function CEmbryoAddDay:unmarshal(os)
  self.animalid = os:unmarshalInt64()
end
function CEmbryoAddDay:sizepolicy(size)
  return size <= 65535
end
return CEmbryoAddDay
