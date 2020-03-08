local SInviteSuccessRes = class("SInviteSuccessRes")
SInviteSuccessRes.TYPEID = 12600838
function SInviteSuccessRes:ctor(roleid1, roleid2)
  self.id = 12600838
  self.roleid1 = roleid1 or nil
  self.roleid2 = roleid2 or nil
end
function SInviteSuccessRes:marshal(os)
  os:marshalInt64(self.roleid1)
  os:marshalInt64(self.roleid2)
end
function SInviteSuccessRes:unmarshal(os)
  self.roleid1 = os:unmarshalInt64()
  self.roleid2 = os:unmarshalInt64()
end
function SInviteSuccessRes:sizepolicy(size)
  return size <= 65535
end
return SInviteSuccessRes
