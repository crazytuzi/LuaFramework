local SKillBossBrd = class("SKillBossBrd")
SKillBossBrd.TYPEID = 12613651
function SKillBossBrd:ctor(roles, bossid)
  self.id = 12613651
  self.roles = roles or {}
  self.bossid = bossid or nil
end
function SKillBossBrd:marshal(os)
  os:marshalCompactUInt32(table.getn(self.roles))
  for _, v in ipairs(self.roles) do
    os:marshalString(v)
  end
  os:marshalInt32(self.bossid)
end
function SKillBossBrd:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.roles, v)
  end
  self.bossid = os:unmarshalInt32()
end
function SKillBossBrd:sizepolicy(size)
  return size <= 65535
end
return SKillBossBrd
