local OctetsStream = require("netio.OctetsStream")
local GetKnockOutContext_Award = class("GetKnockOutContext_Award")
function GetKnockOutContext_Award:ctor(corps_id)
  self.corps_id = corps_id or nil
end
function GetKnockOutContext_Award:marshal(os)
  os:marshalInt64(self.corps_id)
end
function GetKnockOutContext_Award:unmarshal(os)
  self.corps_id = os:unmarshalInt64()
end
return GetKnockOutContext_Award
