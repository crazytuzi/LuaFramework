local CHulaChartReq = class("CHulaChartReq")
CHulaChartReq.TYPEID = 12608773
function CHulaChartReq:ctor(startpos, num)
  self.id = 12608773
  self.startpos = startpos or nil
  self.num = num or nil
end
function CHulaChartReq:marshal(os)
  os:marshalInt32(self.startpos)
  os:marshalInt32(self.num)
end
function CHulaChartReq:unmarshal(os)
  self.startpos = os:unmarshalInt32()
  self.num = os:unmarshalInt32()
end
function CHulaChartReq:sizepolicy(size)
  return size <= 65535
end
return CHulaChartReq
