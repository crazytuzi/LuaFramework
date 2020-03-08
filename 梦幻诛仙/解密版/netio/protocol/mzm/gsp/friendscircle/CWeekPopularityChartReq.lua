local CWeekPopularityChartReq = class("CWeekPopularityChartReq")
CWeekPopularityChartReq.TYPEID = 12625421
function CWeekPopularityChartReq:ctor(start_pos, end_pos)
  self.id = 12625421
  self.start_pos = start_pos or nil
  self.end_pos = end_pos or nil
end
function CWeekPopularityChartReq:marshal(os)
  os:marshalInt32(self.start_pos)
  os:marshalInt32(self.end_pos)
end
function CWeekPopularityChartReq:unmarshal(os)
  self.start_pos = os:unmarshalInt32()
  self.end_pos = os:unmarshalInt32()
end
function CWeekPopularityChartReq:sizepolicy(size)
  return size <= 65535
end
return CWeekPopularityChartReq
