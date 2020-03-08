local OctetsStream = require("netio.OctetsStream")
local GetFinalContext_CreatePrepareWorld = class("GetFinalContext_CreatePrepareWorld")
function GetFinalContext_CreatePrepareWorld:ctor(corps_id, final_stage)
  self.corps_id = corps_id or nil
  self.final_stage = final_stage or nil
end
function GetFinalContext_CreatePrepareWorld:marshal(os)
  os:marshalInt64(self.corps_id)
  os:marshalInt32(self.final_stage)
end
function GetFinalContext_CreatePrepareWorld:unmarshal(os)
  self.corps_id = os:unmarshalInt64()
  self.final_stage = os:unmarshalInt32()
end
return GetFinalContext_CreatePrepareWorld
