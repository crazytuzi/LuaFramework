local SGetRegisterRoleListSuccess = class("SGetRegisterRoleListSuccess")
SGetRegisterRoleListSuccess.TYPEID = 12617004
function SGetRegisterRoleListSuccess:ctor(activity_cfg_id, corps_id, role_list)
  self.id = 12617004
  self.activity_cfg_id = activity_cfg_id or nil
  self.corps_id = corps_id or nil
  self.role_list = role_list or {}
end
function SGetRegisterRoleListSuccess:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt64(self.corps_id)
  os:marshalCompactUInt32(table.getn(self.role_list))
  for _, v in ipairs(self.role_list) do
    os:marshalInt64(v)
  end
end
function SGetRegisterRoleListSuccess:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.corps_id = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    table.insert(self.role_list, v)
  end
end
function SGetRegisterRoleListSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetRegisterRoleListSuccess
