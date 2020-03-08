local SAllStorageInfo = class("SAllStorageInfo")
SAllStorageInfo.TYPEID = 12584806
function SAllStorageInfo:ctor(storages)
  self.id = 12584806
  self.storages = storages or {}
end
function SAllStorageInfo:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.storages) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.storages) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function SAllStorageInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.item.BagInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.storages[k] = v
  end
end
function SAllStorageInfo:sizepolicy(size)
  return size <= 65535
end
return SAllStorageInfo
