local SGetPointRaceRankLocalSuccess = class("SGetPointRaceRankLocalSuccess")
SGetPointRaceRankLocalSuccess.TYPEID = 12617066
function SGetPointRaceRankLocalSuccess:ctor(time_point_cfgid, activity_cfgid, zone, from, to, point_race_ranks)
  self.id = 12617066
  self.time_point_cfgid = time_point_cfgid or nil
  self.activity_cfgid = activity_cfgid or nil
  self.zone = zone or nil
  self.from = from or nil
  self.to = to or nil
  self.point_race_ranks = point_race_ranks or {}
end
function SGetPointRaceRankLocalSuccess:marshal(os)
  os:marshalInt32(self.time_point_cfgid)
  os:marshalInt32(self.activity_cfgid)
  os:marshalInt32(self.zone)
  os:marshalInt32(self.from)
  os:marshalInt32(self.to)
  os:marshalCompactUInt32(table.getn(self.point_race_ranks))
  for _, v in ipairs(self.point_race_ranks) do
    v:marshal(os)
  end
end
function SGetPointRaceRankLocalSuccess:unmarshal(os)
  self.time_point_cfgid = os:unmarshalInt32()
  self.activity_cfgid = os:unmarshalInt32()
  self.zone = os:unmarshalInt32()
  self.from = os:unmarshalInt32()
  self.to = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.crossbattle.PointRaceRankData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.point_race_ranks, v)
  end
end
function SGetPointRaceRankLocalSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetPointRaceRankLocalSuccess
