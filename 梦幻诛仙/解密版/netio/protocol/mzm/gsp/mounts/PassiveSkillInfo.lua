local OctetsStream = require("netio.OctetsStream")
local PassiveSkillInfo = class("PassiveSkillInfo")
function PassiveSkillInfo:ctor(current_passive_skill_cfg_id, refresh_passive_skill_cfg_id)
  self.current_passive_skill_cfg_id = current_passive_skill_cfg_id or nil
  self.refresh_passive_skill_cfg_id = refresh_passive_skill_cfg_id or nil
end
function PassiveSkillInfo:marshal(os)
  os:marshalInt32(self.current_passive_skill_cfg_id)
  os:marshalInt32(self.refresh_passive_skill_cfg_id)
end
function PassiveSkillInfo:unmarshal(os)
  self.current_passive_skill_cfg_id = os:unmarshalInt32()
  self.refresh_passive_skill_cfg_id = os:unmarshalInt32()
end
return PassiveSkillInfo
