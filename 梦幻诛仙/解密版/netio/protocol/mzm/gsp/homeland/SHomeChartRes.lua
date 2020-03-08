local SHomeChartRes = class("SHomeChartRes")
SHomeChartRes.TYPEID = 12605494
function SHomeChartRes:ctor(point, myrank, rankList)
  self.id = 12605494
  self.point = point or nil
  self.myrank = myrank or nil
  self.rankList = rankList or {}
end
function SHomeChartRes:marshal(os)
  os:marshalInt32(self.point)
  os:marshalInt32(self.myrank)
  os:marshalCompactUInt32(table.getn(self.rankList))
  for _, v in ipairs(self.rankList) do
    v:marshal(os)
  end
end
function SHomeChartRes:unmarshal(os)
  self.point = os:unmarshalInt32()
  self.myrank = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.homeland.HomeRankData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.rankList, v)
  end
end
function SHomeChartRes:sizepolicy(size)
  return size <= 65535
end
return SHomeChartRes
