local OctetsStream = require("netio.OctetsStream")
local MountsInfo = class("MountsInfo")
function MountsInfo:ctor(mounts_cfg_id, mounts_rank, color_id, passive_skill_list, remain_time, current_star_level, current_max_active_star_num, current_score, current_ornament_rank, protect_pet_expand_size)
  self.mounts_cfg_id = mounts_cfg_id or nil
  self.mounts_rank = mounts_rank or nil
  self.color_id = color_id or nil
  self.passive_skill_list = passive_skill_list or {}
  self.remain_time = remain_time or nil
  self.current_star_level = current_star_level or nil
  self.current_max_active_star_num = current_max_active_star_num or nil
  self.current_score = current_score or nil
  self.current_ornament_rank = current_ornament_rank or nil
  self.protect_pet_expand_size = protect_pet_expand_size or nil
end
function MountsInfo:marshal(os)
  os:marshalInt32(self.mounts_cfg_id)
  os:marshalInt32(self.mounts_rank)
  os:marshalInt32(self.color_id)
  os:marshalCompactUInt32(table.getn(self.passive_skill_list))
  for _, v in ipairs(self.passive_skill_list) do
    v:marshal(os)
  end
  os:marshalInt64(self.remain_time)
  os:marshalInt32(self.current_star_level)
  os:marshalInt32(self.current_max_active_star_num)
  os:marshalInt32(self.current_score)
  os:marshalInt32(self.current_ornament_rank)
  os:marshalInt32(self.protect_pet_expand_size)
end
function MountsInfo:unmarshal(os)
  self.mounts_cfg_id = os:unmarshalInt32()
  self.mounts_rank = os:unmarshalInt32()
  self.color_id = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.mounts.PassiveSkillInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.passive_skill_list, v)
  end
  self.remain_time = os:unmarshalInt64()
  self.current_star_level = os:unmarshalInt32()
  self.current_max_active_star_num = os:unmarshalInt32()
  self.current_score = os:unmarshalInt32()
  self.current_ornament_rank = os:unmarshalInt32()
  self.protect_pet_expand_size = os:unmarshalInt32()
end
return MountsInfo
