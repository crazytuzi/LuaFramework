local SGetPetArenaInfoFailed = class("SGetPetArenaInfoFailed")
SGetPetArenaInfoFailed.TYPEID = 12628227
SGetPetArenaInfoFailed.ERROR_LEVEL = -1
SGetPetArenaInfoFailed.ERROR_ACTIVITY_JOIN = -2
SGetPetArenaInfoFailed.ERROR_IN_TEAM = -3
function SGetPetArenaInfoFailed:ctor(retcode)
  self.id = 12628227
  self.retcode = retcode or nil
end
function SGetPetArenaInfoFailed:marshal(os)
  os:marshalInt32(self.retcode)
end
function SGetPetArenaInfoFailed:unmarshal(os)
  self.retcode = os:unmarshalInt32()
end
function SGetPetArenaInfoFailed:sizepolicy(size)
  return size <= 65535
end
return SGetPetArenaInfoFailed
