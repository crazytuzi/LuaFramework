local CTaskTalk = class("CTaskTalk")
CTaskTalk.TYPEID = 12592135
function CTaskTalk:ctor(taskId, graphId, talkType, talkIndex)
  self.id = 12592135
  self.taskId = taskId or nil
  self.graphId = graphId or nil
  self.talkType = talkType or nil
  self.talkIndex = talkIndex or nil
end
function CTaskTalk:marshal(os)
  os:marshalInt32(self.taskId)
  os:marshalInt32(self.graphId)
  os:marshalInt32(self.talkType)
  os:marshalInt32(self.talkIndex)
end
function CTaskTalk:unmarshal(os)
  self.taskId = os:unmarshalInt32()
  self.graphId = os:unmarshalInt32()
  self.talkType = os:unmarshalInt32()
  self.talkIndex = os:unmarshalInt32()
end
function CTaskTalk:sizepolicy(size)
  return size <= 65535
end
return CTaskTalk
