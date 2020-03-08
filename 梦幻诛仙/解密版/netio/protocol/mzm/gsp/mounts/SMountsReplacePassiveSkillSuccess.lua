local PassiveSkillInfo = require("netio.protocol.mzm.gsp.mounts.PassiveSkillInfo")
local SMountsReplacePassiveSkillSuccess = class("SMountsReplacePassiveSkillSuccess")
SMountsReplacePassiveSkillSuccess.TYPEID = 12606213
function SMountsReplacePassiveSkillSuccess:ctor(mounts_id, old_passive_skill_cfg_id, refresh_passive_skill_result)
  self.id = 12606213
  self.mounts_id = mounts_id or nil
  self.old_passive_skill_cfg_id = old_passive_skill_cfg_id or nil
  self.refresh_passive_skill_result = refresh_passive_skill_result or PassiveSkillInfo.new()
end
function SMountsReplacePassiveSkillSuccess:marshal(os)
  os:marshalInt64(self.mounts_id)
  os:marshalInt32(self.old_passive_skill_cfg_id)
  self.refresh_passive_skill_result:marshal(os)
end
function SMountsReplacePassiveSkillSuccess:unmarshal(os)
  self.mounts_id = os:unmarshalInt64()
  self.old_passive_skill_cfg_id = os:unmarshalInt32()
  self.refresh_passive_skill_result = PassiveSkillInfo.new()
  self.refresh_passive_skill_result:unmarshal(os)
end
function SMountsReplacePassiveSkillSuccess:sizepolicy(size)
  return size <= 65535
end
return SMountsReplacePassiveSkillSuccess
