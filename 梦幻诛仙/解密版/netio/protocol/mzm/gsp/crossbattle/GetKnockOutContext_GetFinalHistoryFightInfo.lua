local OctetsStream = require("netio.OctetsStream")
local GetKnockOutContext_GetFinalHistoryFightInfo = class("GetKnockOutContext_GetFinalHistoryFightInfo")
function GetKnockOutContext_GetFinalHistoryFightInfo:ctor(session, role_id, req_type)
  self.session = session or nil
  self.role_id = role_id or nil
  self.req_type = req_type or nil
end
function GetKnockOutContext_GetFinalHistoryFightInfo:marshal(os)
  os:marshalInt32(self.session)
  os:marshalInt64(self.role_id)
  os:marshalInt32(self.req_type)
end
function GetKnockOutContext_GetFinalHistoryFightInfo:unmarshal(os)
  self.session = os:unmarshalInt32()
  self.role_id = os:unmarshalInt64()
  self.req_type = os:unmarshalInt32()
end
return GetKnockOutContext_GetFinalHistoryFightInfo
