local OctetsStream = require("netio.OctetsStream")
local TaskData = class("TaskData")
function TaskData:ctor(graphId, taskId, state, conDatas, unConDatas)
  self.graphId = graphId or nil
  self.taskId = taskId or nil
  self.state = state or nil
  self.conDatas = conDatas or {}
  self.unConDatas = unConDatas or {}
end
function TaskData:marshal(os)
  os:marshalInt32(self.graphId)
  os:marshalInt32(self.taskId)
  os:marshalInt32(self.state)
  os:marshalCompactUInt32(table.getn(self.conDatas))
  for _, v in ipairs(self.conDatas) do
    v:marshal(os)
  end
  os:marshalCompactUInt32(table.getn(self.unConDatas))
  for _, v in ipairs(self.unConDatas) do
    os:marshalInt32(v)
  end
end
function TaskData:unmarshal(os)
  self.graphId = os:unmarshalInt32()
  self.taskId = os:unmarshalInt32()
  self.state = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.task.ConData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.conDatas, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.unConDatas, v)
  end
end
return TaskData
