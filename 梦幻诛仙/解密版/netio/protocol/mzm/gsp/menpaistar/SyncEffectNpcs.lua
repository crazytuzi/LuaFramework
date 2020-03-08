local SyncEffectNpcs = class("SyncEffectNpcs")
SyncEffectNpcs.TYPEID = 12612386
function SyncEffectNpcs:ctor(npcCfgids)
  self.id = 12612386
  self.npcCfgids = npcCfgids or {}
end
function SyncEffectNpcs:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.npcCfgids) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.npcCfgids) do
    os:marshalInt32(k)
    os:marshalInt64(v)
  end
end
function SyncEffectNpcs:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt64()
    self.npcCfgids[k] = v
  end
end
function SyncEffectNpcs:sizepolicy(size)
  return size <= 65535
end
return SyncEffectNpcs
