local SBrdRoleGetBuff = class("SBrdRoleGetBuff")
SBrdRoleGetBuff.TYPEID = 12621597
function SBrdRoleGetBuff:ctor(roleid, buff_cfg_id)
  self.id = 12621597
  self.roleid = roleid or nil
  self.buff_cfg_id = buff_cfg_id or nil
end
function SBrdRoleGetBuff:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalInt32(self.buff_cfg_id)
end
function SBrdRoleGetBuff:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.buff_cfg_id = os:unmarshalInt32()
end
function SBrdRoleGetBuff:sizepolicy(size)
  return size <= 65535
end
return SBrdRoleGetBuff
