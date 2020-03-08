local SNotifyPVEFightTip = class("SNotifyPVEFightTip")
SNotifyPVEFightTip.TYPEID = 12620295
function SNotifyPVEFightTip:ctor(fightCount, wantedIdSet)
  self.id = 12620295
  self.fightCount = fightCount or nil
  self.wantedIdSet = wantedIdSet or {}
end
function SNotifyPVEFightTip:marshal(os)
  os:marshalInt32(self.fightCount)
  local _size_ = 0
  for _, _ in pairs(self.wantedIdSet) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, _ in pairs(self.wantedIdSet) do
    os:marshalInt64(k)
  end
end
function SNotifyPVEFightTip:unmarshal(os)
  self.fightCount = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    self.wantedIdSet[v] = v
  end
end
function SNotifyPVEFightTip:sizepolicy(size)
  return size <= 65535
end
return SNotifyPVEFightTip
