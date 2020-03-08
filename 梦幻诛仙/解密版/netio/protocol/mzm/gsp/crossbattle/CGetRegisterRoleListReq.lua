local CGetRegisterRoleListReq = class("CGetRegisterRoleListReq")
CGetRegisterRoleListReq.TYPEID = 12617006
function CGetRegisterRoleListReq:ctor(activity_cfg_id, corps_id)
  self.id = 12617006
  self.activity_cfg_id = activity_cfg_id or nil
  self.corps_id = corps_id or nil
end
function CGetRegisterRoleListReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt64(self.corps_id)
end
function CGetRegisterRoleListReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.corps_id = os:unmarshalInt64()
end
function CGetRegisterRoleListReq:sizepolicy(size)
  return size <= 65535
end
return CGetRegisterRoleListReq
