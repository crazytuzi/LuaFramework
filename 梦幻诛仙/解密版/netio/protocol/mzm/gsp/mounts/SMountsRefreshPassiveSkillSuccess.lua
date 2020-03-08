local PassiveSkillInfo = require("netio.protocol.mzm.gsp.mounts.PassiveSkillInfo")
local SMountsRefreshPassiveSkillSuccess = class("SMountsRefreshPassiveSkillSuccess")
SMountsRefreshPassiveSkillSuccess.TYPEID = 12606211
function SMountsRefreshPassiveSkillSuccess:ctor(mounts_id, refresh_passive_skill_result)
  self.id = 12606211
  self.mounts_id = mounts_id or nil
  self.refresh_passive_skill_result = refresh_passive_skill_result or PassiveSkillInfo.new()
end
function SMountsRefreshPassiveSkillSuccess:marshal(os)
  os:marshalInt64(self.mounts_id)
  self.refresh_passive_skill_result:marshal(os)
end
function SMountsRefreshPassiveSkillSuccess:unmarshal(os)
  self.mounts_id = os:unmarshalInt64()
  self.refresh_passive_skill_result = PassiveSkillInfo.new()
  self.refresh_passive_skill_result:unmarshal(os)
end
function SMountsRefreshPassiveSkillSuccess:sizepolicy(size)
  return size <= 65535
end
return SMountsRefreshPassiveSkillSuccess
