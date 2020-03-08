local OctetsStream = require("netio.OctetsStream")
local GetFinalContext_CheckPanel = class("GetFinalContext_CheckPanel")
function GetFinalContext_CheckPanel:ctor(role_id)
  self.role_id = role_id or nil
end
function GetFinalContext_CheckPanel:marshal(os)
  os:marshalInt64(self.role_id)
end
function GetFinalContext_CheckPanel:unmarshal(os)
  self.role_id = os:unmarshalInt64()
end
return GetFinalContext_CheckPanel
