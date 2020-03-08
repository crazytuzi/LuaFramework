local CGetPointRaceRankLocal = class("CGetPointRaceRankLocal")
CGetPointRaceRankLocal.TYPEID = 12617067
function CGetPointRaceRankLocal:ctor(time_point_cfgid, activity_cfgid, zone, from, to)
  self.id = 12617067
  self.time_point_cfgid = time_point_cfgid or nil
  self.activity_cfgid = activity_cfgid or nil
  self.zone = zone or nil
  self.from = from or nil
  self.to = to or nil
end
function CGetPointRaceRankLocal:marshal(os)
  os:marshalInt32(self.time_point_cfgid)
  os:marshalInt32(self.activity_cfgid)
  os:marshalInt32(self.zone)
  os:marshalInt32(self.from)
  os:marshalInt32(self.to)
end
function CGetPointRaceRankLocal:unmarshal(os)
  self.time_point_cfgid = os:unmarshalInt32()
  self.activity_cfgid = os:unmarshalInt32()
  self.zone = os:unmarshalInt32()
  self.from = os:unmarshalInt32()
  self.to = os:unmarshalInt32()
end
function CGetPointRaceRankLocal:sizepolicy(size)
  return size <= 65535
end
return CGetPointRaceRankLocal
