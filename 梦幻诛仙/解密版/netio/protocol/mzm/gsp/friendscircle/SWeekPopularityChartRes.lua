local SWeekPopularityChartRes = class("SWeekPopularityChartRes")
SWeekPopularityChartRes.TYPEID = 12625416
function SWeekPopularityChartRes:ctor(current_week_popularity_value, my_rank, rank_list)
  self.id = 12625416
  self.current_week_popularity_value = current_week_popularity_value or nil
  self.my_rank = my_rank or nil
  self.rank_list = rank_list or {}
end
function SWeekPopularityChartRes:marshal(os)
  os:marshalInt32(self.current_week_popularity_value)
  os:marshalInt32(self.my_rank)
  os:marshalCompactUInt32(table.getn(self.rank_list))
  for _, v in ipairs(self.rank_list) do
    v:marshal(os)
  end
end
function SWeekPopularityChartRes:unmarshal(os)
  self.current_week_popularity_value = os:unmarshalInt32()
  self.my_rank = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.friendscircle.PopularityRankData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.rank_list, v)
  end
end
function SWeekPopularityChartRes:sizepolicy(size)
  return size <= 65535
end
return SWeekPopularityChartRes
