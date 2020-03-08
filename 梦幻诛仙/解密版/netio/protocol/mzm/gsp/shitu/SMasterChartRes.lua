local SMasterChartRes = class("SMasterChartRes")
SMasterChartRes.TYPEID = 12601620
function SMasterChartRes:ctor(apprenticeSize, myrank, rankList)
  self.id = 12601620
  self.apprenticeSize = apprenticeSize or nil
  self.myrank = myrank or nil
  self.rankList = rankList or {}
end
function SMasterChartRes:marshal(os)
  os:marshalInt32(self.apprenticeSize)
  os:marshalInt32(self.myrank)
  os:marshalCompactUInt32(table.getn(self.rankList))
  for _, v in ipairs(self.rankList) do
    v:marshal(os)
  end
end
function SMasterChartRes:unmarshal(os)
  self.apprenticeSize = os:unmarshalInt32()
  self.myrank = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.shitu.MasterRankData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.rankList, v)
  end
end
function SMasterChartRes:sizepolicy(size)
  return size <= 65535
end
return SMasterChartRes
