local SEnterCrossBattleFinalMapSuccess = class("SEnterCrossBattleFinalMapSuccess")
SEnterCrossBattleFinalMapSuccess.TYPEID = 12617062
function SEnterCrossBattleFinalMapSuccess:ctor(left_seconds)
  self.id = 12617062
  self.left_seconds = left_seconds or nil
end
function SEnterCrossBattleFinalMapSuccess:marshal(os)
  os:marshalInt64(self.left_seconds)
end
function SEnterCrossBattleFinalMapSuccess:unmarshal(os)
  self.left_seconds = os:unmarshalInt64()
end
function SEnterCrossBattleFinalMapSuccess:sizepolicy(size)
  return size <= 65535
end
return SEnterCrossBattleFinalMapSuccess
