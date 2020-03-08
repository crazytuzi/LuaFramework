local CGiveGiftToRoleReq = class("CGiveGiftToRoleReq")
CGiveGiftToRoleReq.TYPEID = 12611074
function CGiveGiftToRoleReq:ctor(roleid, invitationUuid, giftCfgid)
  self.id = 12611074
  self.roleid = roleid or nil
  self.invitationUuid = invitationUuid or nil
  self.giftCfgid = giftCfgid or nil
end
function CGiveGiftToRoleReq:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalInt64(self.invitationUuid)
  os:marshalInt32(self.giftCfgid)
end
function CGiveGiftToRoleReq:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.invitationUuid = os:unmarshalInt64()
  self.giftCfgid = os:unmarshalInt32()
end
function CGiveGiftToRoleReq:sizepolicy(size)
  return size <= 65535
end
return CGiveGiftToRoleReq
