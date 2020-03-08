local STaskInitData = class("STaskInitData")
STaskInitData.TYPEID = 12592137
function STaskInitData:ctor(taskDatas, setGraphRing)
  self.id = 12592137
  self.taskDatas = taskDatas or {}
  self.setGraphRing = setGraphRing or {}
end
function STaskInitData:marshal(os)
  os:marshalCompactUInt32(table.getn(self.taskDatas))
  for _, v in ipairs(self.taskDatas) do
    v:marshal(os)
  end
  local _size_ = 0
  for _, _ in pairs(self.setGraphRing) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.setGraphRing) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function STaskInitData:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.task.TaskData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.taskDatas, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.setGraphRing[k] = v
  end
end
function STaskInitData:sizepolicy(size)
  return size <= 65535
end
return STaskInitData
