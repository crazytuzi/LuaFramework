local CJingjiChartReq = class("CJingjiChartReq")
CJingjiChartReq.TYPEID = 12595728
function CJingjiChartReq:ctor(startpos, num)
  self.id = 12595728
  self.startpos = startpos or nil
  self.num = num or nil
end
function CJingjiChartReq:marshal(os)
  os:marshalInt32(self.startpos)
  os:marshalInt32(self.num)
end
function CJingjiChartReq:unmarshal(os)
  self.startpos = os:unmarshalInt32()
  self.num = os:unmarshalInt32()
end
function CJingjiChartReq:sizepolicy(size)
  return size <= 65535
end
return CJingjiChartReq
