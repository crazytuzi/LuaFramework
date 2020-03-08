local SJoinFightReq = class("SJoinFightReq")
SJoinFightReq.TYPEID = 12592150
function SJoinFightReq:ctor(taskId, sessionId)
  self.id = 12592150
  self.taskId = taskId or nil
  self.sessionId = sessionId or nil
end
function SJoinFightReq:marshal(os)
  os:marshalInt32(self.taskId)
  os:marshalInt64(self.sessionId)
end
function SJoinFightReq:unmarshal(os)
  self.taskId = os:unmarshalInt32()
  self.sessionId = os:unmarshalInt64()
end
function SJoinFightReq:sizepolicy(size)
  return size <= 65535
end
return SJoinFightReq
