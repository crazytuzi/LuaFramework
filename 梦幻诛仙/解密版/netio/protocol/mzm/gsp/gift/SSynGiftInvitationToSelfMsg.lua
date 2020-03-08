local RoleInfo = require("netio.protocol.mzm.gsp.gift.RoleInfo")
local SSynGiftInvitationToSelfMsg = class("SSynGiftInvitationToSelfMsg")
SSynGiftInvitationToSelfMsg.TYPEID = 12611073
function SSynGiftInvitationToSelfMsg:ctor(roleInfo, invitationUuid, giftType, msgArgs, inviteSecs)
  self.id = 12611073
  self.roleInfo = roleInfo or RoleInfo.new()
  self.invitationUuid = invitationUuid or nil
  self.giftType = giftType or nil
  self.msgArgs = msgArgs or {}
  self.inviteSecs = inviteSecs or nil
end
function SSynGiftInvitationToSelfMsg:marshal(os)
  self.roleInfo:marshal(os)
  os:marshalInt64(self.invitationUuid)
  os:marshalInt32(self.giftType)
  os:marshalCompactUInt32(table.getn(self.msgArgs))
  for _, v in ipairs(self.msgArgs) do
    os:marshalString(v)
  end
  os:marshalInt32(self.inviteSecs)
end
function SSynGiftInvitationToSelfMsg:unmarshal(os)
  self.roleInfo = RoleInfo.new()
  self.roleInfo:unmarshal(os)
  self.invitationUuid = os:unmarshalInt64()
  self.giftType = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.msgArgs, v)
  end
  self.inviteSecs = os:unmarshalInt32()
end
function SSynGiftInvitationToSelfMsg:sizepolicy(size)
  return size <= 65535
end
return SSynGiftInvitationToSelfMsg
