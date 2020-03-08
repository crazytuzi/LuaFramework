local SCreateErrAlreadyHaveCorps = class("SCreateErrAlreadyHaveCorps")
SCreateErrAlreadyHaveCorps.TYPEID = 12617479
function SCreateErrAlreadyHaveCorps:ctor(roleId2Name)
  self.id = 12617479
  self.roleId2Name = roleId2Name or {}
end
function SCreateErrAlreadyHaveCorps:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.roleId2Name) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.roleId2Name) do
    os:marshalInt64(k)
    os:marshalOctets(v)
  end
end
function SCreateErrAlreadyHaveCorps:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local v = os:unmarshalOctets()
    self.roleId2Name[k] = v
  end
end
function SCreateErrAlreadyHaveCorps:sizepolicy(size)
  return size <= 65535
end
return SCreateErrAlreadyHaveCorps
