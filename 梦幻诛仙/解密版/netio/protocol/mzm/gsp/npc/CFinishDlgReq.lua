local CFinishDlgReq = class("CFinishDlgReq")
CFinishDlgReq.TYPEID = 12586756
function CFinishDlgReq:ctor(npcId, taskId)
  self.id = 12586756
  self.npcId = npcId or nil
  self.taskId = taskId or nil
end
function CFinishDlgReq:marshal(os)
  os:marshalInt32(self.npcId)
  os:marshalInt32(self.taskId)
end
function CFinishDlgReq:unmarshal(os)
  self.npcId = os:unmarshalInt32()
  self.taskId = os:unmarshalInt32()
end
function CFinishDlgReq:sizepolicy(size)
  return size <= 65535
end
return CFinishDlgReq
