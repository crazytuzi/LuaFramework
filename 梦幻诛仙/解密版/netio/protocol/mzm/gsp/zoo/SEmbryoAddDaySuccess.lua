local SEmbryoAddDaySuccess = class("SEmbryoAddDaySuccess")
SEmbryoAddDaySuccess.TYPEID = 12615425
function SEmbryoAddDaySuccess:ctor(animalid, last_time)
  self.id = 12615425
  self.animalid = animalid or nil
  self.last_time = last_time or nil
end
function SEmbryoAddDaySuccess:marshal(os)
  os:marshalInt64(self.animalid)
  os:marshalInt32(self.last_time)
end
function SEmbryoAddDaySuccess:unmarshal(os)
  self.animalid = os:unmarshalInt64()
  self.last_time = os:unmarshalInt32()
end
function SEmbryoAddDaySuccess:sizepolicy(size)
  return size <= 65535
end
return SEmbryoAddDaySuccess
