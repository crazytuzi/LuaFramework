local SupdateHuSong = class("SupdateHuSong")
SupdateHuSong.TYPEID = 12587553
function SupdateHuSong:ctor(husongMap)
  self.id = 12587553
  self.husongMap = husongMap or {}
end
function SupdateHuSong:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.husongMap) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.husongMap) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SupdateHuSong:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.husongMap[k] = v
  end
end
function SupdateHuSong:sizepolicy(size)
  return size <= 65535
end
return SupdateHuSong
