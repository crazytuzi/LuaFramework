local SGiveGiftToRoleErrorRes = class("SGiveGiftToRoleErrorRes")
SGiveGiftToRoleErrorRes.TYPEID = 12611078
SGiveGiftToRoleErrorRes.ALREADY_SEND = 1
SGiveGiftToRoleErrorRes.OUT_OF_DATE = 2
function SGiveGiftToRoleErrorRes:ctor(ret)
  self.id = 12611078
  self.ret = ret or nil
end
function SGiveGiftToRoleErrorRes:marshal(os)
  os:marshalInt32(self.ret)
end
function SGiveGiftToRoleErrorRes:unmarshal(os)
  self.ret = os:unmarshalInt32()
end
function SGiveGiftToRoleErrorRes:sizepolicy(size)
  return size <= 65535
end
return SGiveGiftToRoleErrorRes
