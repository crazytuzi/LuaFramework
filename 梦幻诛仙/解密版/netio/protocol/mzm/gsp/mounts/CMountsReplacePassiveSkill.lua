local CMountsReplacePassiveSkill = class("CMountsReplacePassiveSkill")
CMountsReplacePassiveSkill.TYPEID = 12606230
function CMountsReplacePassiveSkill:ctor(mounts_id, passive_skill_cfg_id)
  self.id = 12606230
  self.mounts_id = mounts_id or nil
  self.passive_skill_cfg_id = passive_skill_cfg_id or nil
end
function CMountsReplacePassiveSkill:marshal(os)
  os:marshalInt64(self.mounts_id)
  os:marshalInt32(self.passive_skill_cfg_id)
end
function CMountsReplacePassiveSkill:unmarshal(os)
  self.mounts_id = os:unmarshalInt64()
  self.passive_skill_cfg_id = os:unmarshalInt32()
end
function CMountsReplacePassiveSkill:sizepolicy(size)
  return size <= 65535
end
return CMountsReplacePassiveSkill
