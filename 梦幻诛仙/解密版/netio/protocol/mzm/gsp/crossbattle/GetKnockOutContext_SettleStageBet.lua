local OctetsStream = require("netio.OctetsStream")
local GetKnockOutContext_SettleStageBet = class("GetKnockOutContext_SettleStageBet")
function GetKnockOutContext_SettleStageBet:ctor(stage)
  self.stage = stage or nil
end
function GetKnockOutContext_SettleStageBet:marshal(os)
  os:marshalInt32(self.stage)
end
function GetKnockOutContext_SettleStageBet:unmarshal(os)
  self.stage = os:unmarshalInt32()
end
return GetKnockOutContext_SettleStageBet
