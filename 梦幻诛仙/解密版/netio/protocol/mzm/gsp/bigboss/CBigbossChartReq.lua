local CBigbossChartReq = class("CBigbossChartReq")
CBigbossChartReq.TYPEID = 12598026
function CBigbossChartReq:ctor(startpos, num, ocp)
  self.id = 12598026
  self.startpos = startpos or nil
  self.num = num or nil
  self.ocp = ocp or nil
end
function CBigbossChartReq:marshal(os)
  os:marshalInt32(self.startpos)
  os:marshalInt32(self.num)
  os:marshalInt32(self.ocp)
end
function CBigbossChartReq:unmarshal(os)
  self.startpos = os:unmarshalInt32()
  self.num = os:unmarshalInt32()
  self.ocp = os:unmarshalInt32()
end
function CBigbossChartReq:sizepolicy(size)
  return size <= 65535
end
return CBigbossChartReq
