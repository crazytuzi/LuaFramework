local OctetsStream = require("netio.OctetsStream")
local ModelInfo = require("netio.protocol.mzm.gsp.pubdata.ModelInfo")
local TeamDispositionMemberInfo = class("TeamDispositionMemberInfo")
TeamDispositionMemberInfo.DT_TEAM_MEMBER = 0
TeamDispositionMemberInfo.DT_PARTNER = 1
function TeamDispositionMemberInfo:ctor(teamDispositionMember_id, dispositionMemberType, model)
  self.teamDispositionMember_id = teamDispositionMember_id or nil
  self.dispositionMemberType = dispositionMemberType or nil
  self.model = model or ModelInfo.new()
end
function TeamDispositionMemberInfo:marshal(os)
  os:marshalInt64(self.teamDispositionMember_id)
  os:marshalInt32(self.dispositionMemberType)
  self.model:marshal(os)
end
function TeamDispositionMemberInfo:unmarshal(os)
  self.teamDispositionMember_id = os:unmarshalInt64()
  self.dispositionMemberType = os:unmarshalInt32()
  self.model = ModelInfo.new()
  self.model:unmarshal(os)
end
return TeamDispositionMemberInfo
