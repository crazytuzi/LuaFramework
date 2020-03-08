local OctetsStream = require("netio.OctetsStream")
local GetKnockOutContext_GetFightZoneInfo = class("GetKnockOutContext_GetFightZoneInfo")
function GetKnockOutContext_GetFightZoneInfo:ctor(role_id)
  self.role_id = role_id or nil
end
function GetKnockOutContext_GetFightZoneInfo:marshal(os)
  os:marshalInt64(self.role_id)
end
function GetKnockOutContext_GetFightZoneInfo:unmarshal(os)
  self.role_id = os:unmarshalInt64()
end
return GetKnockOutContext_GetFightZoneInfo
