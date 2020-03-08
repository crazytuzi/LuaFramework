local SParaseleneChartRes = class("SParaseleneChartRes")
SParaseleneChartRes.TYPEID = 12598294
function SParaseleneChartRes:ctor(seconds, myrank, rankList)
  self.id = 12598294
  self.seconds = seconds or nil
  self.myrank = myrank or nil
  self.rankList = rankList or {}
end
function SParaseleneChartRes:marshal(os)
  os:marshalInt32(self.seconds)
  os:marshalInt32(self.myrank)
  os:marshalCompactUInt32(table.getn(self.rankList))
  for _, v in ipairs(self.rankList) do
    v:marshal(os)
  end
end
function SParaseleneChartRes:unmarshal(os)
  self.seconds = os:unmarshalInt32()
  self.myrank = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.paraselene.ParaseleneRankData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.rankList, v)
  end
end
function SParaseleneChartRes:sizepolicy(size)
  return size <= 65535
end
return SParaseleneChartRes
