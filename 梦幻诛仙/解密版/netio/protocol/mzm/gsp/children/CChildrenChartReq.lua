local CChildrenChartReq = class("CChildrenChartReq")
CChildrenChartReq.TYPEID = 12609432
function CChildrenChartReq:ctor(start_pos, end_pos)
  self.id = 12609432
  self.start_pos = start_pos or nil
  self.end_pos = end_pos or nil
end
function CChildrenChartReq:marshal(os)
  os:marshalInt32(self.start_pos)
  os:marshalInt32(self.end_pos)
end
function CChildrenChartReq:unmarshal(os)
  self.start_pos = os:unmarshalInt32()
  self.end_pos = os:unmarshalInt32()
end
function CChildrenChartReq:sizepolicy(size)
  return size <= 65535
end
return CChildrenChartReq
