local SynSurpriseGraphFinishInfo = class("SynSurpriseGraphFinishInfo")
SynSurpriseGraphFinishInfo.TYPEID = 12592155
function SynSurpriseGraphFinishInfo:ctor(finishGraphInfo)
  self.id = 12592155
  self.finishGraphInfo = finishGraphInfo or {}
end
function SynSurpriseGraphFinishInfo:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.finishGraphInfo) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.finishGraphInfo) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SynSurpriseGraphFinishInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.finishGraphInfo[k] = v
  end
end
function SynSurpriseGraphFinishInfo:sizepolicy(size)
  return size <= 65535
end
return SynSurpriseGraphFinishInfo
