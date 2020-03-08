local SSyncGangHelpRemove = class("SSyncGangHelpRemove")
SSyncGangHelpRemove.TYPEID = 793410
function SSyncGangHelpRemove:ctor(uId)
  self.id = 793410
  self.uId = uId or {}
end
function SSyncGangHelpRemove:marshal(os)
  os:marshalCompactUInt32(table.getn(self.uId))
  for _, v in ipairs(self.uId) do
    os:marshalInt64(v)
  end
end
function SSyncGangHelpRemove:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    table.insert(self.uId, v)
  end
end
function SSyncGangHelpRemove:sizepolicy(size)
  return size <= 65535
end
return SSyncGangHelpRemove
