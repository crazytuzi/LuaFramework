local SSynBigbossChart = class("SSynBigbossChart")
SSynBigbossChart.TYPEID = 12598025
function SSynBigbossChart:ctor(ocp, page, rankList)
  self.id = 12598025
  self.ocp = ocp or nil
  self.page = page or nil
  self.rankList = rankList or {}
end
function SSynBigbossChart:marshal(os)
  os:marshalInt32(self.ocp)
  os:marshalInt32(self.page)
  os:marshalCompactUInt32(table.getn(self.rankList))
  for _, v in ipairs(self.rankList) do
    v:marshal(os)
  end
end
function SSynBigbossChart:unmarshal(os)
  self.ocp = os:unmarshalInt32()
  self.page = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.bigboss.BigbossRankData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.rankList, v)
  end
end
function SSynBigbossChart:sizepolicy(size)
  return size <= 65535
end
return SSynBigbossChart
