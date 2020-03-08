local SyncAnimalInfos = class("SyncAnimalInfos")
SyncAnimalInfos.TYPEID = 12615428
function SyncAnimalInfos:ctor(animals)
  self.id = 12615428
  self.animals = animals or {}
end
function SyncAnimalInfos:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.animals) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.animals) do
    os:marshalInt64(k)
    v:marshal(os)
  end
end
function SyncAnimalInfos:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local BeanClazz = require("netio.protocol.mzm.gsp.zoo.AnimalInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.animals[k] = v
  end
end
function SyncAnimalInfos:sizepolicy(size)
  return size <= 65535
end
return SyncAnimalInfos
