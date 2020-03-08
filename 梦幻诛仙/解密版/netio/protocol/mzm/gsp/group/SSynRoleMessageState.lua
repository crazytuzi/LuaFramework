local SSynRoleMessageState = class("SSynRoleMessageState")
SSynRoleMessageState.TYPEID = 12605222
function SSynRoleMessageState:ctor(groupid2message_state)
  self.id = 12605222
  self.groupid2message_state = groupid2message_state or {}
end
function SSynRoleMessageState:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.groupid2message_state) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.groupid2message_state) do
    os:marshalInt64(k)
    os:marshalInt32(v)
  end
end
function SSynRoleMessageState:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local v = os:unmarshalInt32()
    self.groupid2message_state[k] = v
  end
end
function SSynRoleMessageState:sizepolicy(size)
  return size <= 65535
end
return SSynRoleMessageState
