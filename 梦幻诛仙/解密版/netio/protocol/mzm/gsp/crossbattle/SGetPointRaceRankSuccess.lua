local SGetPointRaceRankSuccess = class("SGetPointRaceRankSuccess")
SGetPointRaceRankSuccess.TYPEID = 12617024
function SGetPointRaceRankSuccess:ctor(rank_type, from, to, point_race_ranks)
  self.id = 12617024
  self.rank_type = rank_type or nil
  self.from = from or nil
  self.to = to or nil
  self.point_race_ranks = point_race_ranks or {}
end
function SGetPointRaceRankSuccess:marshal(os)
  os:marshalUInt8(self.rank_type)
  os:marshalInt32(self.from)
  os:marshalInt32(self.to)
  os:marshalCompactUInt32(table.getn(self.point_race_ranks))
  for _, v in ipairs(self.point_race_ranks) do
    v:marshal(os)
  end
end
function SGetPointRaceRankSuccess:unmarshal(os)
  self.rank_type = os:unmarshalUInt8()
  self.from = os:unmarshalInt32()
  self.to = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.crossbattle.PointRaceRankData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.point_race_ranks, v)
  end
end
function SGetPointRaceRankSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetPointRaceRankSuccess
