local CMasterChartReq = class("CMasterChartReq")
CMasterChartReq.TYPEID = 12601603
function CMasterChartReq:ctor(startPos, endPos)
  self.id = 12601603
  self.startPos = startPos or nil
  self.endPos = endPos or nil
end
function CMasterChartReq:marshal(os)
  os:marshalInt32(self.startPos)
  os:marshalInt32(self.endPos)
end
function CMasterChartReq:unmarshal(os)
  self.startPos = os:unmarshalInt32()
  self.endPos = os:unmarshalInt32()
end
function CMasterChartReq:sizepolicy(size)
  return size <= 65535
end
return CMasterChartReq
