local CAutoAssignPrefReq = class("CAutoAssignPrefReq")
CAutoAssignPrefReq.TYPEID = 12585987
CAutoAssignPrefReq.PROP_SYS_1 = 0
CAutoAssignPrefReq.PROP_SYS_2 = 1
CAutoAssignPrefReq.PROP_SYS_3 = 2
function CAutoAssignPrefReq:ctor(propSys, assignPropMap)
  self.id = 12585987
  self.propSys = propSys or nil
  self.assignPropMap = assignPropMap or {}
end
function CAutoAssignPrefReq:marshal(os)
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
function CAutoAssignPrefReq:unmarshal(os)
  self.propSys = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.assignPropMap[k] = v
  end
end
function CAutoAssignPrefReq:sizepolicy(size)
  return size <= 65535
end
return CAutoAssignPrefReq
