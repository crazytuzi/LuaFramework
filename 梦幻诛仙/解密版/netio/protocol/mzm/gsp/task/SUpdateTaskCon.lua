local ConData = require("netio.protocol.mzm.gsp.task.ConData")
local SUpdateTaskCon = class("SUpdateTaskCon")
SUpdateTaskCon.TYPEID = 12592130
function SUpdateTaskCon:ctor(taskId, graphId, conData)
  self.id = 12592130
  self.taskId = taskId or nil
  self.graphId = graphId or nil
  self.conData = conData or ConData.new()
end
function SUpdateTaskCon:marshal(os)
  os:marshalInt32(self.taskId)
  os:marshalInt32(self.graphId)
  self.conData:marshal(os)
end
function SUpdateTaskCon:unmarshal(os)
  self.taskId = os:unmarshalInt32()
  self.graphId = os:unmarshalInt32()
  self.conData = ConData.new()
  self.conData:unmarshal(os)
end
function SUpdateTaskCon:sizepolicy(size)
  return size <= 65535
end
return SUpdateTaskCon
