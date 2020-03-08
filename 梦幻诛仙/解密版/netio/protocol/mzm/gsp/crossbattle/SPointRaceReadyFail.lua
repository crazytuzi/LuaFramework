local SPointRaceReadyFail = class("SPointRaceReadyFail")
SPointRaceReadyFail.TYPEID = 12617011
SPointRaceReadyFail.ERROR_CORPS_NOT_PROMOTION = -1
SPointRaceReadyFail.ERROR_POINT_RACE_TIME = -2
SPointRaceReadyFail.ERROR_NOT_IN_TEAM = -3
SPointRaceReadyFail.ERROR_TEAM_MEMBER_NOT_ENOUGH = -4
SPointRaceReadyFail.ERROR_TEAM_NOT_MATCH_CORPS = -5
SPointRaceReadyFail.ERROR_CORPS_ZONE = -6
SPointRaceReadyFail.ERROR_UN_KNOW = -7
SPointRaceReadyFail.ERROR_GEN_TOKEN = -8
SPointRaceReadyFail.ERROR_DATA_TRANSFOR = -9
SPointRaceReadyFail.ERROR_PENDING = -10
function SPointRaceReadyFail:ctor(retcode, activity_cfgid, index)
  self.id = 12617011
  self.retcode = retcode or nil
  self.activity_cfgid = activity_cfgid or nil
  self.index = index or nil
end
function SPointRaceReadyFail:marshal(os)
  os:marshalInt32(self.retcode)
  os:marshalInt32(self.activity_cfgid)
  os:marshalInt32(self.index)
end
function SPointRaceReadyFail:unmarshal(os)
  self.retcode = os:unmarshalInt32()
  self.activity_cfgid = os:unmarshalInt32()
  self.index = os:unmarshalInt32()
end
function SPointRaceReadyFail:sizepolicy(size)
  return size <= 65535
end
return SPointRaceReadyFail
