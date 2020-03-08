local SAnimalMateSuccess = class("SAnimalMateSuccess")
SAnimalMateSuccess.TYPEID = 12615434
function SAnimalMateSuccess:ctor(animalid, target_animalid, last_time, award_cfgid)
  self.id = 12615434
  self.animalid = animalid or nil
  self.target_animalid = target_animalid or nil
  self.last_time = last_time or nil
  self.award_cfgid = award_cfgid or nil
end
function SAnimalMateSuccess:marshal(os)
  os:marshalInt64(self.animalid)
  os:marshalInt64(self.target_animalid)
  os:marshalInt32(self.last_time)
  os:marshalInt32(self.award_cfgid)
end
function SAnimalMateSuccess:unmarshal(os)
  self.animalid = os:unmarshalInt64()
  self.target_animalid = os:unmarshalInt64()
  self.last_time = os:unmarshalInt32()
  self.award_cfgid = os:unmarshalInt32()
end
function SAnimalMateSuccess:sizepolicy(size)
  return size <= 65535
end
return SAnimalMateSuccess
