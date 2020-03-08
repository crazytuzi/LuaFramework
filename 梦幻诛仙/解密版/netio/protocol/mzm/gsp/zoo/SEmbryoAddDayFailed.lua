local SEmbryoAddDayFailed = class("SEmbryoAddDayFailed")
SEmbryoAddDayFailed.TYPEID = 12615426
SEmbryoAddDayFailed.ERROR_ADDED = -1
SEmbryoAddDayFailed.ERROR_MAX_DAY = -2
function SEmbryoAddDayFailed:ctor(retcode, animalid)
  self.id = 12615426
  self.retcode = retcode or nil
  self.animalid = animalid or nil
end
function SEmbryoAddDayFailed:marshal(os)
  os:marshalInt32(self.retcode)
  os:marshalInt64(self.animalid)
end
function SEmbryoAddDayFailed:unmarshal(os)
  self.retcode = os:unmarshalInt32()
  self.animalid = os:unmarshalInt64()
end
function SEmbryoAddDayFailed:sizepolicy(size)
  return size <= 65535
end
return SEmbryoAddDayFailed
