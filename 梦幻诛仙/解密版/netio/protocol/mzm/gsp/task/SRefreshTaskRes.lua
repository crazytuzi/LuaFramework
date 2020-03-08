local SRefreshTaskRes = class("SRefreshTaskRes")
SRefreshTaskRes.TYPEID = 12592129
function SRefreshTaskRes:ctor(npcId, taskStates)
  self.id = 12592129
  self.npcId = npcId or nil
  self.taskStates = taskStates or {}
end
function SRefreshTaskRes:marshal(os)
  os:marshalInt32(self.npcId)
  os:marshalCompactUInt32(table.getn(self.taskStates))
  for _, v in ipairs(self.taskStates) do
    v:marshal(os)
  end
end
function SRefreshTaskRes:unmarshal(os)
  self.npcId = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.task.TaskState")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.taskStates, v)
  end
end
function SRefreshTaskRes:sizepolicy(size)
  return size <= 65535
end
return SRefreshTaskRes
