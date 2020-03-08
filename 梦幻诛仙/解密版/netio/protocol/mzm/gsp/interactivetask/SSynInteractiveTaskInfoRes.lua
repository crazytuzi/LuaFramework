local TaskInfo = require("netio.protocol.mzm.gsp.interactivetask.TaskInfo")
local SSynInteractiveTaskInfoRes = class("SSynInteractiveTaskInfoRes")
SSynInteractiveTaskInfoRes.TYPEID = 12610315
function SSynInteractiveTaskInfoRes:ctor(typeid, taskInfo)
  self.id = 12610315
  self.typeid = typeid or nil
  self.taskInfo = taskInfo or TaskInfo.new()
end
function SSynInteractiveTaskInfoRes:marshal(os)
  os:marshalInt32(self.typeid)
  self.taskInfo:marshal(os)
end
function SSynInteractiveTaskInfoRes:unmarshal(os)
  self.typeid = os:unmarshalInt32()
  self.taskInfo = TaskInfo.new()
  self.taskInfo:unmarshal(os)
end
function SSynInteractiveTaskInfoRes:sizepolicy(size)
  return size <= 65535
end
return SSynInteractiveTaskInfoRes
