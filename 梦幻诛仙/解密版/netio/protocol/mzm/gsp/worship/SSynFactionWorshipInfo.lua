local SSynFactionWorshipInfo = class("SSynFactionWorshipInfo")
SSynFactionWorshipInfo.TYPEID = 12612609
function SSynFactionWorshipInfo:ctor(worshipId2num)
  self.id = 12612609
  self.worshipId2num = worshipId2num or {}
end
function SSynFactionWorshipInfo:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.worshipId2num) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.worshipId2num) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SSynFactionWorshipInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.worshipId2num[k] = v
  end
end
function SSynFactionWorshipInfo:sizepolicy(size)
  return size <= 65535
end
return SSynFactionWorshipInfo
