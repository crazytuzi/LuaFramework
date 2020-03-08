local STaskTalk = class("STaskTalk")
STaskTalk.TYPEID = 12592136
function STaskTalk:ctor(taskId, graphId, talkType, talkIndex)
  self.id = 12592136
  self.taskId = taskId or nil
  self.graphId = graphId or nil
  self.talkType = talkType or nil
  self.talkIndex = talkIndex or nil
end
function STaskTalk:marshal(os)
  os:marshalInt32(self.taskId)
  os:marshalInt32(self.graphId)
  os:marshalInt32(self.talkType)
  os:marshalInt32(self.talkIndex)
end
function STaskTalk:unmarshal(os)
  self.taskId = os:unmarshalInt32()
  self.graphId = os:unmarshalInt32()
  self.talkType = os:unmarshalInt32()
  self.talkIndex = os:unmarshalInt32()
end
function STaskTalk:sizepolicy(size)
  return size <= 65535
end
return STaskTalk
