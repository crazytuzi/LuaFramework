local SGetAwardFailed = class("SGetAwardFailed")
SGetAwardFailed.TYPEID = 12615443
SGetAwardFailed.ERROR_AWARD_NOT_EXIST = -1
SGetAwardFailed.ERROR_BAG_FULL = -2
function SGetAwardFailed:ctor(retcode, animalid)
  self.id = 12615443
  self.retcode = retcode or nil
  self.animalid = animalid or nil
end
function SGetAwardFailed:marshal(os)
  os:marshalInt32(self.retcode)
  os:marshalInt64(self.animalid)
end
function SGetAwardFailed:unmarshal(os)
  self.retcode = os:unmarshalInt32()
  self.animalid = os:unmarshalInt64()
end
function SGetAwardFailed:sizepolicy(size)
  return size <= 65535
end
return SGetAwardFailed
