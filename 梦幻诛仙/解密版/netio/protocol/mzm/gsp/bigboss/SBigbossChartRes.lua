local SBigbossChartRes = class("SBigbossChartRes")
SBigbossChartRes.TYPEID = 12598024
function SBigbossChartRes:ctor(startpos, num, ocp, point, myrank, rankList)
  self.id = 12598024
  self.startpos = startpos or nil
  self.num = num or nil
  self.ocp = ocp or nil
  self.point = point or nil
  self.myrank = myrank or nil
  self.rankList = rankList or {}
end
function SBigbossChartRes:marshal(os)
  os:marshalInt32(self.startpos)
  os:marshalInt32(self.num)
  os:marshalInt32(self.ocp)
  os:marshalInt32(self.point)
  os:marshalInt32(self.myrank)
  os:marshalCompactUInt32(table.getn(self.rankList))
  for _, v in ipairs(self.rankList) do
    v:marshal(os)
  end
end
function SBigbossChartRes:unmarshal(os)
  self.startpos = os:unmarshalInt32()
  self.num = os:unmarshalInt32()
  self.ocp = os:unmarshalInt32()
  self.point = os:unmarshalInt32()
  self.myrank = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.bigboss.BigbossRankData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.rankList, v)
  end
end
function SBigbossChartRes:sizepolicy(size)
  return size <= 65535
end
return SBigbossChartRes
