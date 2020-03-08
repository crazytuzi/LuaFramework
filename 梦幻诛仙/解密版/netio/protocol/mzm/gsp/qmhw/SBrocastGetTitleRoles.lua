local SBrocastGetTitleRoles = class("SBrocastGetTitleRoles")
SBrocastGetTitleRoles.TYPEID = 12601873
function SBrocastGetTitleRoles:ctor(rolename)
  self.id = 12601873
  self.rolename = rolename or {}
end
function SBrocastGetTitleRoles:marshal(os)
  os:marshalCompactUInt32(table.getn(self.rolename))
  for _, v in ipairs(self.rolename) do
    os:marshalString(v)
  end
end
function SBrocastGetTitleRoles:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.rolename, v)
  end
end
function SBrocastGetTitleRoles:sizepolicy(size)
  return size <= 65535
end
return SBrocastGetTitleRoles
