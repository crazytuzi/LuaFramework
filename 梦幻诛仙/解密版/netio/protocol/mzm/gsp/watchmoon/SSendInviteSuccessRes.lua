local SSendInviteSuccessRes = class("SSendInviteSuccessRes")
SSendInviteSuccessRes.TYPEID = 12600846
function SSendInviteSuccessRes:ctor(roleid2)
  self.id = 12600846
  self.roleid2 = roleid2 or nil
end
function SSendInviteSuccessRes:marshal(os)
  os:marshalInt64(self.roleid2)
end
function SSendInviteSuccessRes:unmarshal(os)
  self.roleid2 = os:unmarshalInt64()
end
function SSendInviteSuccessRes:sizepolicy(size)
  return size <= 65535
end
return SSendInviteSuccessRes
