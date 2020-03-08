local SGetRoleList = class("SGetRoleList")
SGetRoleList.TYPEID = 12590089
function SGetRoleList:ctor(roles, roleModels)
  self.id = 12590089
  self.roles = roles or {}
  self.roleModels = roleModels or {}
end
function SGetRoleList:marshal(os)
  os:marshalCompactUInt32(table.getn(self.roles))
  for _, v in ipairs(self.roles) do
    v:marshal(os)
  end
  local _size_ = 0
  for _, _ in pairs(self.roleModels) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.roleModels) do
    os:marshalInt64(k)
    v:marshal(os)
  end
end
function SGetRoleList:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.RoleInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.roles, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local BeanClazz = require("netio.protocol.mzm.gsp.pubdata.ModelInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.roleModels[k] = v
  end
end
function SGetRoleList:sizepolicy(size)
  return size <= 10240
end
return SGetRoleList
