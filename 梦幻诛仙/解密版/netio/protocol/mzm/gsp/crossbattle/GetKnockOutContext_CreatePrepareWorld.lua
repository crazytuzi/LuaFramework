local OctetsStream = require("netio.OctetsStream")
local GetKnockOutContext_CreatePrepareWorld = class("GetKnockOutContext_CreatePrepareWorld")
function GetKnockOutContext_CreatePrepareWorld:ctor(corps_id, fight_stage)
  self.corps_id = corps_id or nil
  self.fight_stage = fight_stage or nil
end
function GetKnockOutContext_CreatePrepareWorld:marshal(os)
  os:marshalInt64(self.corps_id)
  os:marshalInt32(self.fight_stage)
end
function GetKnockOutContext_CreatePrepareWorld:unmarshal(os)
  self.corps_id = os:unmarshalInt64()
  self.fight_stage = os:unmarshalInt32()
end
return GetKnockOutContext_CreatePrepareWorld
