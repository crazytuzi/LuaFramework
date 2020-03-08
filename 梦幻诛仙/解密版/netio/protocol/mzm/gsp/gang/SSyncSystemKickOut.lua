local SSyncSystemKickOut = class("SSyncSystemKickOut")
SSyncSystemKickOut.TYPEID = 12589868
function SSyncSystemKickOut:ctor(roleList)
  self.id = 12589868
  self.roleList = roleList or {}
end
function SSyncSystemKickOut:marshal(os)
  os:marshalCompactUInt32(table.getn(self.roleList))
  for _, v in ipairs(self.roleList) do
    os:marshalInt64(v)
  end
end
function SSyncSystemKickOut:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    table.insert(self.roleList, v)
  end
end
function SSyncSystemKickOut:sizepolicy(size)
  return size <= 65535
end
return SSyncSystemKickOut
