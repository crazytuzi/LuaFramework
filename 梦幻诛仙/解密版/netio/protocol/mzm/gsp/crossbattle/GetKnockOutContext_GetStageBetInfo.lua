local OctetsStream = require("netio.OctetsStream")
local GetKnockOutContext_GetStageBetInfo = class("GetKnockOutContext_GetStageBetInfo")
function GetKnockOutContext_GetStageBetInfo:ctor(role_id, stage)
  self.role_id = role_id or nil
  self.stage = stage or nil
end
function GetKnockOutContext_GetStageBetInfo:marshal(os)
  os:marshalInt64(self.role_id)
  os:marshalInt32(self.stage)
end
function GetKnockOutContext_GetStageBetInfo:unmarshal(os)
  self.role_id = os:unmarshalInt64()
  self.stage = os:unmarshalInt32()
end
return GetKnockOutContext_GetStageBetInfo
