local OctetsStream = require("netio.OctetsStream")
local GetKnockOutContext_SettleRoleStageBet = class("GetKnockOutContext_SettleRoleStageBet")
function GetKnockOutContext_SettleRoleStageBet:ctor(role_id, stage)
  self.role_id = role_id or nil
  self.stage = stage or nil
end
function GetKnockOutContext_SettleRoleStageBet:marshal(os)
  os:marshalInt64(self.role_id)
  os:marshalInt32(self.stage)
end
function GetKnockOutContext_SettleRoleStageBet:unmarshal(os)
  self.role_id = os:unmarshalInt64()
  self.stage = os:unmarshalInt32()
end
return GetKnockOutContext_SettleRoleStageBet
