local OctetsStream = require("netio.OctetsStream")
local TaskInfo = class("TaskInfo")
function TaskInfo:ctor(finishedGraphs, currentGraph, isCommander, endTime)
  self.finishedGraphs = finishedGraphs or {}
  self.currentGraph = currentGraph or nil
  self.isCommander = isCommander or nil
  self.endTime = endTime or nil
end
function TaskInfo:marshal(os)
  os:marshalCompactUInt32(table.getn(self.finishedGraphs))
  for _, v in ipairs(self.finishedGraphs) do
    os:marshalInt32(v)
  end
  os:marshalInt32(self.currentGraph)
  os:marshalInt32(self.isCommander)
  os:marshalInt64(self.endTime)
end
function TaskInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.finishedGraphs, v)
  end
  self.currentGraph = os:unmarshalInt32()
  self.isCommander = os:unmarshalInt32()
  self.endTime = os:unmarshalInt64()
end
return TaskInfo
