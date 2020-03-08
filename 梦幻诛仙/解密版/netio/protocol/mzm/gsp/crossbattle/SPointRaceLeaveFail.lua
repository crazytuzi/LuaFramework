local SPointRaceLeaveFail = class("SPointRaceLeaveFail")
SPointRaceLeaveFail.TYPEID = 12617019
SPointRaceLeaveFail.ERROR_IN_FIGHT = -1
SPointRaceLeaveFail.ERROR_TEAM = -2
SPointRaceLeaveFail.ERROR_NOT_TEAM_LEADER = -3
SPointRaceLeaveFail.ERROR_TEAM_MEMBER = -4
SPointRaceLeaveFail.ERROR_CORPS_MEMBER = -5
function SPointRaceLeaveFail:ctor(retcode)
  self.id = 12617019
  self.retcode = retcode or nil
end
function SPointRaceLeaveFail:marshal(os)
  os:marshalInt32(self.retcode)
end
function SPointRaceLeaveFail:unmarshal(os)
  self.retcode = os:unmarshalInt32()
end
function SPointRaceLeaveFail:sizepolicy(size)
  return size <= 65535
end
return SPointRaceLeaveFail
