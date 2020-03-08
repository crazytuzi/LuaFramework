local SBrocastQMHWItem = class("SBrocastQMHWItem")
SBrocastQMHWItem.TYPEID = 12601871
function SBrocastQMHWItem:ctor(roleid, rolename, item2count)
  self.id = 12601871
  self.roleid = roleid or nil
  self.rolename = rolename or nil
  self.item2count = item2count or {}
end
function SBrocastQMHWItem:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalString(self.rolename)
  local _size_ = 0
  for _, _ in pairs(self.item2count) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.item2count) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SBrocastQMHWItem:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.rolename = os:unmarshalString()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.item2count[k] = v
  end
end
function SBrocastQMHWItem:sizepolicy(size)
  return size <= 65535
end
return SBrocastQMHWItem
