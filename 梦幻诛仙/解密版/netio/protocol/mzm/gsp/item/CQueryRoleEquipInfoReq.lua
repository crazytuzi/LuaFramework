local CQueryRoleEquipInfoReq = class("CQueryRoleEquipInfoReq")
CQueryRoleEquipInfoReq.TYPEID = 12584834
function CQueryRoleEquipInfoReq:ctor(roleid)
  self.id = 12584834
  self.roleid = roleid or nil
end
function CQueryRoleEquipInfoReq:marshal(os)
  os:marshalInt64(self.roleid)
end
function CQueryRoleEquipInfoReq:unmarshal(os)
  self.roleid = os:unmarshalInt64()
end
function CQueryRoleEquipInfoReq:sizepolicy(size)
  return size <= 65535
end
return CQueryRoleEquipInfoReq
