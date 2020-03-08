local RoleInfo = require("netio.protocol.mzm.gsp.gift.RoleInfo")
local SSynRoleReceiveGiftRes = class("SSynRoleReceiveGiftRes")
SSynRoleReceiveGiftRes.TYPEID = 12611075
function SSynRoleReceiveGiftRes:ctor(roleInfo, giftCfgid, receiveSecs)
  self.id = 12611075
  self.roleInfo = roleInfo or RoleInfo.new()
  self.giftCfgid = giftCfgid or nil
  self.receiveSecs = receiveSecs or nil
end
function SSynRoleReceiveGiftRes:marshal(os)
  self.roleInfo:marshal(os)
  os:marshalInt32(self.giftCfgid)
  os:marshalInt32(self.receiveSecs)
end
function SSynRoleReceiveGiftRes:unmarshal(os)
  self.roleInfo = RoleInfo.new()
  self.roleInfo:unmarshal(os)
  self.giftCfgid = os:unmarshalInt32()
  self.receiveSecs = os:unmarshalInt32()
end
function SSynRoleReceiveGiftRes:sizepolicy(size)
  return size <= 65535
end
return SSynRoleReceiveGiftRes
