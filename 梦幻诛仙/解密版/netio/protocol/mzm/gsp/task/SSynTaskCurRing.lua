local SSynTaskCurRing = class("SSynTaskCurRing")
SSynTaskCurRing.TYPEID = 12592138
SSynTaskCurRing.FINISH_TASK = 1
SSynTaskCurRing.GIVEUP_TASK = 2
SSynTaskCurRing.COPY_LEADER_TASK = 3
SSynTaskCurRing.ACTIVITY_TASK_INIT = 4
function SSynTaskCurRing:ctor(graphId, totalRing, curRing, reason)
  self.id = 12592138
  self.graphId = graphId or nil
  self.totalRing = totalRing or nil
  self.curRing = curRing or nil
  self.reason = reason or nil
end
function SSynTaskCurRing:marshal(os)
  os:marshalInt32(self.graphId)
  os:marshalInt32(self.totalRing)
  os:marshalInt32(self.curRing)
  os:marshalInt32(self.reason)
end
function SSynTaskCurRing:unmarshal(os)
  self.graphId = os:unmarshalInt32()
  self.totalRing = os:unmarshalInt32()
  self.curRing = os:unmarshalInt32()
  self.reason = os:unmarshalInt32()
end
function SSynTaskCurRing:sizepolicy(size)
  return size <= 65535
end
return SSynTaskCurRing
