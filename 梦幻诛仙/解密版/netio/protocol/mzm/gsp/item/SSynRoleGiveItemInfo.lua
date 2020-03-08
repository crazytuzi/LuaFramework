local SSynRoleGiveItemInfo = class("SSynRoleGiveItemInfo")
SSynRoleGiveItemInfo.TYPEID = 12584773
function SSynRoleGiveItemInfo:ctor(roleid2count, roleid2yuanbao)
  self.id = 12584773
  self.roleid2count = roleid2count or {}
  self.roleid2yuanbao = roleid2yuanbao or {}
end
function SSynRoleGiveItemInfo:marshal(os)
  do
    local _size_ = 0
    for _, _ in pairs(self.roleid2count) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.roleid2count) do
      os:marshalInt64(k)
      os:marshalInt32(v)
    end
  end
  local _size_ = 0
  for _, _ in pairs(self.roleid2yuanbao) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.roleid2yuanbao) do
    os:marshalInt64(k)
    os:marshalInt64(v)
  end
end
function SSynRoleGiveItemInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local v = os:unmarshalInt32()
    self.roleid2count[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local v = os:unmarshalInt64()
    self.roleid2yuanbao[k] = v
  end
end
function SSynRoleGiveItemInfo:sizepolicy(size)
  return size <= 65535
end
return SSynRoleGiveItemInfo
