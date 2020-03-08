local SSynRolePlantTreeInfo = class("SSynRolePlantTreeInfo")
SSynRolePlantTreeInfo.TYPEID = 12611587
function SSynRolePlantTreeInfo:ctor(activity_cfg_id, award_section_ids, has_get_activity_complete_award, add_point_times, remove_special_state_award_times)
  self.id = 12611587
  self.activity_cfg_id = activity_cfg_id or nil
  self.award_section_ids = award_section_ids or {}
  self.has_get_activity_complete_award = has_get_activity_complete_award or nil
  self.add_point_times = add_point_times or nil
  self.remove_special_state_award_times = remove_special_state_award_times or nil
end
function SSynRolePlantTreeInfo:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  do
    local _size_ = 0
    for _, _ in pairs(self.award_section_ids) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, _ in pairs(self.award_section_ids) do
      os:marshalInt32(k)
    end
  end
  os:marshalInt32(self.has_get_activity_complete_award)
  os:marshalInt32(self.add_point_times)
  os:marshalInt32(self.remove_special_state_award_times)
end
function SSynRolePlantTreeInfo:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    self.award_section_ids[v] = v
  end
  self.has_get_activity_complete_award = os:unmarshalInt32()
  self.add_point_times = os:unmarshalInt32()
  self.remove_special_state_award_times = os:unmarshalInt32()
end
function SSynRolePlantTreeInfo:sizepolicy(size)
  return size <= 65535
end
return SSynRolePlantTreeInfo
