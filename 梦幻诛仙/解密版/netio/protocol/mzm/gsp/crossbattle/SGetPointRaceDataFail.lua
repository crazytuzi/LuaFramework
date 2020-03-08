local SGetPointRaceDataFail = class("SGetPointRaceDataFail")
SGetPointRaceDataFail.TYPEID = 12617025
function SGetPointRaceDataFail:ctor(retcode)
  self.id = 12617025
  self.retcode = retcode or nil
end
function SGetPointRaceDataFail:marshal(os)
  os:marshalInt32(self.retcode)
end
function SGetPointRaceDataFail:unmarshal(os)
  self.retcode = os:unmarshalInt32()
end
function SGetPointRaceDataFail:sizepolicy(size)
  return size <= 65535
end
return SGetPointRaceDataFail
