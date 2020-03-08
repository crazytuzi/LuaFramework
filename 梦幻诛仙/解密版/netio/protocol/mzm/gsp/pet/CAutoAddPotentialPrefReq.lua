local CAutoAddPotentialPrefReq = class("CAutoAddPotentialPrefReq")
CAutoAddPotentialPrefReq.TYPEID = 12590616
function CAutoAddPotentialPrefReq:ctor(petId, propMap)
  self.id = 12590616
  self.petId = petId or nil
  self.propMap = propMap or {}
end
function CAutoAddPotentialPrefReq:marshal(os)
  os:marshalInt64(self.petId)
  local _size_ = 0
  for _, _ in pairs(self.propMap) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.propMap) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function CAutoAddPotentialPrefReq:unmarshal(os)
  self.petId = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.propMap[k] = v
  end
end
function CAutoAddPotentialPrefReq:sizepolicy(size)
  return size <= 65535
end
return CAutoAddPotentialPrefReq
