local SGetPointRaceRankLocalFail = class("SGetPointRaceRankLocalFail")
SGetPointRaceRankLocalFail.TYPEID = 12617065
SGetPointRaceRankLocalFail.ERROR_ZONE_NUM = -1
SGetPointRaceRankLocalFail.ERROR_TIME_POINT = -2
SGetPointRaceRankLocalFail.ERROR_NOT_START = -3
SGetPointRaceRankLocalFail.ERROR_NOT_END = -4
SGetPointRaceRankLocalFail.ERROR_SYSTEM = -5
function SGetPointRaceRankLocalFail:ctor(retcode, time_point_cfgid, activity_cfgid, zone, from, to)
  self.id = 12617065
  self.retcode = retcode or nil
  self.time_point_cfgid = time_point_cfgid or nil
  self.activity_cfgid = activity_cfgid or nil
  self.zone = zone or nil
  self.from = from or nil
  self.to = to or nil
end
function SGetPointRaceRankLocalFail:marshal(os)
  os:marshalInt32(self.retcode)
  os:marshalInt32(self.time_point_cfgid)
  os:marshalInt32(self.activity_cfgid)
  os:marshalInt32(self.zone)
  os:marshalInt32(self.from)
  os:marshalInt32(self.to)
end
function SGetPointRaceRankLocalFail:unmarshal(os)
  self.retcode = os:unmarshalInt32()
  self.time_point_cfgid = os:unmarshalInt32()
  self.activity_cfgid = os:unmarshalInt32()
  self.zone = os:unmarshalInt32()
  self.from = os:unmarshalInt32()
  self.to = os:unmarshalInt32()
end
function SGetPointRaceRankLocalFail:sizepolicy(size)
  return size <= 65535
end
return SGetPointRaceRankLocalFail
