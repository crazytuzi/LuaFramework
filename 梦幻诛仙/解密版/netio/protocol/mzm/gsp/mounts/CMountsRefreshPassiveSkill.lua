local CMountsRefreshPassiveSkill = class("CMountsRefreshPassiveSkill")
CMountsRefreshPassiveSkill.TYPEID = 12606225
function CMountsRefreshPassiveSkill:ctor(mounts_id, passive_skill_id, is_use_yuan_bao, client_current_yuan_bao, need_yuan_bao)
  self.id = 12606225
  self.mounts_id = mounts_id or nil
  self.passive_skill_id = passive_skill_id or nil
  self.is_use_yuan_bao = is_use_yuan_bao or nil
  self.client_current_yuan_bao = client_current_yuan_bao or nil
  self.need_yuan_bao = need_yuan_bao or nil
end
function CMountsRefreshPassiveSkill:marshal(os)
  os:marshalInt64(self.mounts_id)
  os:marshalInt32(self.passive_skill_id)
  os:marshalInt32(self.is_use_yuan_bao)
  os:marshalInt64(self.client_current_yuan_bao)
  os:marshalInt32(self.need_yuan_bao)
end
function CMountsRefreshPassiveSkill:unmarshal(os)
  self.mounts_id = os:unmarshalInt64()
  self.passive_skill_id = os:unmarshalInt32()
  self.is_use_yuan_bao = os:unmarshalInt32()
  self.client_current_yuan_bao = os:unmarshalInt64()
  self.need_yuan_bao = os:unmarshalInt32()
end
function CMountsRefreshPassiveSkill:sizepolicy(size)
  return size <= 65535
end
return CMountsRefreshPassiveSkill
