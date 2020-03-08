local CChartReq = class("CChartReq")
CChartReq.TYPEID = 12596742
function CChartReq:ctor(page)
  self.id = 12596742
  self.page = page or nil
end
function CChartReq:marshal(os)
  os:marshalInt32(self.page)
end
function CChartReq:unmarshal(os)
  self.page = os:unmarshalInt32()
end
function CChartReq:sizepolicy(size)
  return size <= 65535
end
return CChartReq
