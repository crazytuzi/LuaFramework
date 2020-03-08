local SSynMultiRoleAwardItemRes = class("SSynMultiRoleAwardItemRes")
SSynMultiRoleAwardItemRes.TYPEID = 12583435
function SSynMultiRoleAwardItemRes:ctor(roles, notAwardRoles, awardUUid)
  self.id = 12583435
  self.roles = roles or {}
  self.notAwardRoles = notAwardRoles or {}
  self.awardUUid = awardUUid or nil
end
function SSynMultiRoleAwardItemRes:marshal(os)
  os:marshalCompactUInt32(table.getn(self.roles))
  for _, v in ipairs(self.roles) do
    v:marshal(os)
  end
  os:marshalCompactUInt32(table.getn(self.notAwardRoles))
  for _, v in ipairs(self.notAwardRoles) do
    os:marshalInt64(v)
  end
  os:marshalInt64(self.awardUUid)
end
function SSynMultiRoleAwardItemRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.award.RoleInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.roles, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    table.insert(self.notAwardRoles, v)
  end
  self.awardUUid = os:unmarshalInt64()
end
function SSynMultiRoleAwardItemRes:sizepolicy(size)
  return size <= 65535
end
return SSynMultiRoleAwardItemRes
