local OctetsStream = require("netio.OctetsStream")
local GetKnockOutContext_GetFinalHistoryTopThreeCorpsInfo = class("GetKnockOutContext_GetFinalHistoryTopThreeCorpsInfo")
function GetKnockOutContext_GetFinalHistoryTopThreeCorpsInfo:ctor(session, role_id, rank, corps_id)
  self.session = session or nil
  self.role_id = role_id or nil
  self.rank = rank or nil
  self.corps_id = corps_id or nil
end
function GetKnockOutContext_GetFinalHistoryTopThreeCorpsInfo:marshal(os)
  os:marshalInt32(self.session)
  os:marshalInt64(self.role_id)
  os:marshalInt32(self.rank)
  os:marshalInt64(self.corps_id)
end
function GetKnockOutContext_GetFinalHistoryTopThreeCorpsInfo:unmarshal(os)
  self.session = os:unmarshalInt32()
  self.role_id = os:unmarshalInt64()
  self.rank = os:unmarshalInt32()
  self.corps_id = os:unmarshalInt64()
end
return GetKnockOutContext_GetFinalHistoryTopThreeCorpsInfo
