local CFinishTaskReq = class("CFinishTaskReq")
CFinishTaskReq.TYPEID = 12592131
function CFinishTaskReq:ctor(taskId, graphId, giveoutPet, giveoutItem)
  self.id = 12592131
  self.taskId = taskId or nil
  self.graphId = graphId or nil
  self.giveoutPet = giveoutPet or {}
  self.giveoutItem = giveoutItem or {}
end
function CFinishTaskReq:marshal(os)
  os:marshalInt32(self.taskId)
  os:marshalInt32(self.graphId)
  os:marshalCompactUInt32(table.getn(self.giveoutPet))
  for _, v in ipairs(self.giveoutPet) do
    os:marshalInt64(v)
  end
  os:marshalCompactUInt32(table.getn(self.giveoutItem))
  for _, v in ipairs(self.giveoutItem) do
    v:marshal(os)
  end
end
function CFinishTaskReq:unmarshal(os)
  self.taskId = os:unmarshalInt32()
  self.graphId = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    table.insert(self.giveoutPet, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.task.GiveoutItemBean")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.giveoutItem, v)
  end
end
function CFinishTaskReq:sizepolicy(size)
  return size <= 65535
end
return CFinishTaskReq
