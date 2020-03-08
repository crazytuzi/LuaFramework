local OctetsStream = require("netio.OctetsStream")
local GetKnockOutContext_GetFinalChampionCorpsInfo = class("GetKnockOutContext_GetFinalChampionCorpsInfo")
function GetKnockOutContext_GetFinalChampionCorpsInfo:ctor(session, activity_cfg_id)
  self.session = session or nil
  self.activity_cfg_id = activity_cfg_id or nil
end
function GetKnockOutContext_GetFinalChampionCorpsInfo:marshal(os)
  os:marshalInt32(self.session)
  os:marshalInt32(self.activity_cfg_id)
end
function GetKnockOutContext_GetFinalChampionCorpsInfo:unmarshal(os)
  self.session = os:unmarshalInt32()
  self.activity_cfg_id = os:unmarshalInt32()
end
return GetKnockOutContext_GetFinalChampionCorpsInfo
