local CGetChart = class("CGetChart")
CGetChart.TYPEID = 12628240
function CGetChart:ctor(start_rank, num)
  self.id = 12628240
  self.start_rank = start_rank or nil
  self.num = num or nil
end
function CGetChart:marshal(os)
  os:marshalInt32(self.start_rank)
  os:marshalInt32(self.num)
end
function CGetChart:unmarshal(os)
  self.start_rank = os:unmarshalInt32()
  self.num = os:unmarshalInt32()
end
function CGetChart:sizepolicy(size)
  return size <= 65535
end
return CGetChart
