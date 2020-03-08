local CParaseleneChartReq = class("CParaseleneChartReq")
CParaseleneChartReq.TYPEID = 12598295
function CParaseleneChartReq:ctor(startpos, num)
  self.id = 12598295
  self.startpos = startpos or nil
  self.num = num or nil
end
function CParaseleneChartReq:marshal(os)
  os:marshalInt32(self.startpos)
  os:marshalInt32(self.num)
end
function CParaseleneChartReq:unmarshal(os)
  self.startpos = os:unmarshalInt32()
  self.num = os:unmarshalInt32()
end
function CParaseleneChartReq:sizepolicy(size)
  return size <= 65535
end
return CParaseleneChartReq
