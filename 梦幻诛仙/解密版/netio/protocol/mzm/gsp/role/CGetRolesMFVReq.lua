local CGetRolesMFVReq = class("CGetRolesMFVReq")
CGetRolesMFVReq.TYPEID = 12586031
function CGetRolesMFVReq:ctor(roleIds)
  self.id = 12586031
  self.roleIds = roleIds or {}
end
function CGetRolesMFVReq:marshal(os)
  os:marshalCompactUInt32(table.getn(self.roleIds))
  for _, v in ipairs(self.roleIds) do
    os:marshalInt64(v)
  end
end
function CGetRolesMFVReq:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    table.insert(self.roleIds, v)
  end
end
function CGetRolesMFVReq:sizepolicy(size)
  return size <= 65535
end
return CGetRolesMFVReq
