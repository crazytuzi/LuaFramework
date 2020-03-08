local CAfterUseTaskItem = class("CAfterUseTaskItem")
CAfterUseTaskItem.TYPEID = 12592142
function CAfterUseTaskItem:ctor(taskId, graphId, taskItemId)
  self.id = 12592142
  self.taskId = taskId or nil
  self.graphId = graphId or nil
  self.taskItemId = taskItemId or nil
end
function CAfterUseTaskItem:marshal(os)
  os:marshalInt32(self.taskId)
  os:marshalInt32(self.graphId)
  os:marshalInt32(self.taskItemId)
end
function CAfterUseTaskItem:unmarshal(os)
  self.taskId = os:unmarshalInt32()
  self.graphId = os:unmarshalInt32()
  self.taskItemId = os:unmarshalInt32()
end
function CAfterUseTaskItem:sizepolicy(size)
  return size <= 65535
end
return CAfterUseTaskItem
