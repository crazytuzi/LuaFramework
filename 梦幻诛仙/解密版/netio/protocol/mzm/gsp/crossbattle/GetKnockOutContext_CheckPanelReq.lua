local OctetsStream = require("netio.OctetsStream")
local GetKnockOutContext_CheckPanelReq = class("GetKnockOutContext_CheckPanelReq")
function GetKnockOutContext_CheckPanelReq:ctor(role_id)
  self.role_id = role_id or nil
end
function GetKnockOutContext_CheckPanelReq:marshal(os)
  os:marshalInt64(self.role_id)
end
function GetKnockOutContext_CheckPanelReq:unmarshal(os)
  self.role_id = os:unmarshalInt64()
end
return GetKnockOutContext_CheckPanelReq
