local SSyncRolesOnMultiRoleMounts = class("SSyncRolesOnMultiRoleMounts")
SSyncRolesOnMultiRoleMounts.TYPEID = 12606253
function SSyncRolesOnMultiRoleMounts:ctor(team_id, mounts_cfg_id, on_mounts_role_id_map)
  self.id = 12606253
  self.team_id = team_id or nil
  self.mounts_cfg_id = mounts_cfg_id or nil
  self.on_mounts_role_id_map = on_mounts_role_id_map or {}
end
function SSyncRolesOnMultiRoleMounts:marshal(os)
  os:marshalInt64(self.team_id)
  os:marshalInt32(self.mounts_cfg_id)
  local _size_ = 0
  for _, _ in pairs(self.on_mounts_role_id_map) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.on_mounts_role_id_map) do
    os:marshalInt32(k)
    os:marshalInt64(v)
  end
end
function SSyncRolesOnMultiRoleMounts:unmarshal(os)
  self.team_id = os:unmarshalInt64()
  self.mounts_cfg_id = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt64()
    self.on_mounts_role_id_map[k] = v
  end
end
function SSyncRolesOnMultiRoleMounts:sizepolicy(size)
  return size <= 65535
end
return SSyncRolesOnMultiRoleMounts
