local OctetsStream = require("netio.OctetsStream")
local GetKnockOutContext_GetSpecialFightZoneStage = class("GetKnockOutContext_GetSpecialFightZoneStage")
function GetKnockOutContext_GetSpecialFightZoneStage:ctor(role_id, fight_stage)
  self.role_id = role_id or nil
  self.fight_stage = fight_stage or nil
end
function GetKnockOutContext_GetSpecialFightZoneStage:marshal(os)
  os:marshalInt64(self.role_id)
  os:marshalInt32(self.fight_stage)
end
function GetKnockOutContext_GetSpecialFightZoneStage:unmarshal(os)
  self.role_id = os:unmarshalInt64()
  self.fight_stage = os:unmarshalInt32()
end
return GetKnockOutContext_GetSpecialFightZoneStage
