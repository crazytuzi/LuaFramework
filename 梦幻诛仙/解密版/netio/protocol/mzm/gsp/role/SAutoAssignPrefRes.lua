local SAutoAssignPrefRes = class("SAutoAssignPrefRes")
SAutoAssignPrefRes.TYPEID = 12585988
SAutoAssignPrefRes.PROP_SYS_1 = 0
SAutoAssignPrefRes.PROP_SYS_2 = 1
SAutoAssignPrefRes.PROP_SYS_3 = 2
function SAutoAssignPrefRes:ctor(propSys, assignPropMap)
  self.id = 12585988
  self.propSys = propSys or nil
  self.assignPropMap = assignPropMap or {}
end
function SAutoAssignPrefRes:marshal(os)
  os:marshalInt32(self.propSys)
  local _size_ = 0
  for _, _ in pairs(self.assignPropMap) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.assignPropMap) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SAutoAssignPrefRes:unmarshal(os)
  self.propSys = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.assignPropMap[k] = v
  end
end
function SAutoAssignPrefRes:sizepolicy(size)
  return size <= 65535
end
return SAutoAssignPrefRes
