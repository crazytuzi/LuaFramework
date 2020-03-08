local CGiveItem = class("CGiveItem")
CGiveItem.TYPEID = 12584755
function CGiveItem:ctor(roleid, uuid2num)
  self.id = 12584755
  self.roleid = roleid or nil
  self.uuid2num = uuid2num or {}
end
function CGiveItem:marshal(os)
  os:marshalInt64(self.roleid)
  local _size_ = 0
  for _, _ in pairs(self.uuid2num) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.uuid2num) do
    os:marshalInt64(k)
    os:marshalInt32(v)
  end
end
function CGiveItem:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local v = os:unmarshalInt32()
    self.uuid2num[k] = v
  end
end
function CGiveItem:sizepolicy(size)
  return size <= 65535
end
return CGiveItem
