local SSyncGRCFriends = class("SSyncGRCFriends")
SSyncGRCFriends.TYPEID = 12587040
function SSyncGRCFriends:ctor(roleids)
  self.id = 12587040
  self.roleids = roleids or {}
end
function SSyncGRCFriends:marshal(os)
  os:marshalCompactUInt32(table.getn(self.roleids))
  for _, v in ipairs(self.roleids) do
    os:marshalInt64(v)
  end
end
function SSyncGRCFriends:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    table.insert(self.roleids, v)
  end
end
function SSyncGRCFriends:sizepolicy(size)
  return size <= 65535
end
return SSyncGRCFriends
