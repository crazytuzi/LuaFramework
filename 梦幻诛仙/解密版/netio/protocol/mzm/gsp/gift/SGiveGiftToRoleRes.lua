local SGiveGiftToRoleRes = class("SGiveGiftToRoleRes")
SGiveGiftToRoleRes.TYPEID = 12611077
function SGiveGiftToRoleRes:ctor(roleid, invitationUuid, giftCfgid)
  self.id = 12611077
  self.roleid = roleid or nil
  self.invitationUuid = invitationUuid or nil
  self.giftCfgid = giftCfgid or nil
end
function SGiveGiftToRoleRes:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalInt64(self.invitationUuid)
  os:marshalInt32(self.giftCfgid)
end
function SGiveGiftToRoleRes:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.invitationUuid = os:unmarshalInt64()
  self.giftCfgid = os:unmarshalInt32()
end
function SGiveGiftToRoleRes:sizepolicy(size)
  return size <= 65535
end
return SGiveGiftToRoleRes
