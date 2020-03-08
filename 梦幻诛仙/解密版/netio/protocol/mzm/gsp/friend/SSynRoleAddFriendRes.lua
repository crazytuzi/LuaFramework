local SSynRoleAddFriendRes = class("SSynRoleAddFriendRes")
SSynRoleAddFriendRes.TYPEID = 12587036
SSynRoleAddFriendRes.TYPE_MASSWEDDING = 1
function SSynRoleAddFriendRes:ctor(triggerType, roleid, name, extraInfo)
  self.id = 12587036
  self.triggerType = triggerType or nil
  self.roleid = roleid or nil
  self.name = name or nil
  self.extraInfo = extraInfo or {}
end
function SSynRoleAddFriendRes:marshal(os)
  os:marshalInt32(self.triggerType)
  os:marshalInt64(self.roleid)
  os:marshalString(self.name)
  local _size_ = 0
  for _, _ in pairs(self.extraInfo) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.extraInfo) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SSynRoleAddFriendRes:unmarshal(os)
  self.triggerType = os:unmarshalInt32()
  self.roleid = os:unmarshalInt64()
  self.name = os:unmarshalString()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.extraInfo[k] = v
  end
end
function SSynRoleAddFriendRes:sizepolicy(size)
  return size <= 65535
end
return SSynRoleAddFriendRes
