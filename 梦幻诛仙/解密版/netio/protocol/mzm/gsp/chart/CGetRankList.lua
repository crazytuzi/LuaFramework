local CGetRankList = class("CGetRankList")
CGetRankList.TYPEID = 12587780
function CGetRankList:ctor(chartType, fromNo, toNo)
  self.id = 12587780
  self.chartType = chartType or nil
  self.fromNo = fromNo or nil
  self.toNo = toNo or nil
end
function CGetRankList:marshal(os)
  os:marshalInt32(self.chartType)
  os:marshalInt32(self.fromNo)
  os:marshalInt32(self.toNo)
end
function CGetRankList:unmarshal(os)
  self.chartType = os:unmarshalInt32()
  self.fromNo = os:unmarshalInt32()
  self.toNo = os:unmarshalInt32()
end
function CGetRankList:sizepolicy(size)
  return size <= 65535
end
return CGetRankList
