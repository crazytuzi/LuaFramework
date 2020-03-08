local CHomeChartReq = class("CHomeChartReq")
CHomeChartReq.TYPEID = 12605495
function CHomeChartReq:ctor(startpos, num)
  self.id = 12605495
  self.startpos = startpos or nil
  self.num = num or nil
end
function CHomeChartReq:marshal(os)
  os:marshalInt32(self.startpos)
  os:marshalInt32(self.num)
end
function CHomeChartReq:unmarshal(os)
  self.startpos = os:unmarshalInt32()
  self.num = os:unmarshalInt32()
end
function CHomeChartReq:sizepolicy(size)
  return size <= 65535
end
return CHomeChartReq
