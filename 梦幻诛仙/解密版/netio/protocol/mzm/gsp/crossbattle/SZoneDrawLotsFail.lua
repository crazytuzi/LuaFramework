local SZoneDrawLotsFail = class("SZoneDrawLotsFail")
SZoneDrawLotsFail.TYPEID = 12617001
SZoneDrawLotsFail.ERROR_STAGE = -1
SZoneDrawLotsFail.ERROR_NOT_TEAM_LEADER = -2
SZoneDrawLotsFail.ERROR_DRAW_LOTS = -3
SZoneDrawLotsFail.ERROR_SYSTEM = -4
SZoneDrawLotsFail.ERROR_NOT_PROMOTION = -5
function SZoneDrawLotsFail:ctor(retcode, activity_cfgid)
  self.id = 12617001
  self.retcode = retcode or nil
  self.activity_cfgid = activity_cfgid or nil
end
function SZoneDrawLotsFail:marshal(os)
  os:marshalInt32(self.retcode)
  os:marshalInt32(self.activity_cfgid)
end
function SZoneDrawLotsFail:unmarshal(os)
  self.retcode = os:unmarshalInt32()
  self.activity_cfgid = os:unmarshalInt32()
end
function SZoneDrawLotsFail:sizepolicy(size)
  return size <= 65535
end
return SZoneDrawLotsFail
