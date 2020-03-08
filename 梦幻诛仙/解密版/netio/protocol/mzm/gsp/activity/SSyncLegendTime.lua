local SSyncLegendTime = class("SSyncLegendTime")
SSyncLegendTime.TYPEID = 12587526
function SSyncLegendTime:ctor(graphId, taskId, endTime)
  self.id = 12587526
  self.graphId = graphId or nil
  self.taskId = taskId or nil
  self.endTime = endTime or nil
end
function SSyncLegendTime:marshal(os)
  os:marshalInt32(self.graphId)
  os:marshalInt32(self.taskId)
  os:marshalInt64(self.endTime)
end
function SSyncLegendTime:unmarshal(os)
  self.graphId = os:unmarshalInt32()
  self.taskId = os:unmarshalInt32()
  self.endTime = os:unmarshalInt64()
end
function SSyncLegendTime:sizepolicy(size)
  return size <= 65535
end
return SSyncLegendTime
