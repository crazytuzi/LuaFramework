local SCannotAcceptTask = class("SCannotAcceptTask")
SCannotAcceptTask.TYPEID = 12592144
function SCannotAcceptTask:ctor(graphId, taskId, conIds)
  self.id = 12592144
  self.graphId = graphId or nil
  self.taskId = taskId or nil
  self.conIds = conIds or {}
end
function SCannotAcceptTask:marshal(os)
  os:marshalInt32(self.graphId)
  os:marshalInt32(self.taskId)
  os:marshalCompactUInt32(table.getn(self.conIds))
  for _, v in ipairs(self.conIds) do
    os:marshalInt32(v)
  end
end
function SCannotAcceptTask:unmarshal(os)
  self.graphId = os:unmarshalInt32()
  self.taskId = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.conIds, v)
  end
end
function SCannotAcceptTask:sizepolicy(size)
  return size <= 65535
end
return SCannotAcceptTask
