local OctetsStream = require("netio.OctetsStream")
local GetFightStageEndCorpsInfo_FinalHistory = class("GetFightStageEndCorpsInfo_FinalHistory")
function GetFightStageEndCorpsInfo_FinalHistory:ctor(role_id, rank, session)
  self.role_id = role_id or nil
  self.rank = rank or nil
  self.session = session or nil
end
function GetFightStageEndCorpsInfo_FinalHistory:marshal(os)
  os:marshalInt64(self.role_id)
  os:marshalInt32(self.rank)
  os:marshalInt32(self.session)
end
function GetFightStageEndCorpsInfo_FinalHistory:unmarshal(os)
  self.role_id = os:unmarshalInt64()
  self.rank = os:unmarshalInt32()
  self.session = os:unmarshalInt32()
end
return GetFightStageEndCorpsInfo_FinalHistory
