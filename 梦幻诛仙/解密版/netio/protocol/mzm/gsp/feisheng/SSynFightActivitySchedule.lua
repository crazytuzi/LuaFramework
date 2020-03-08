local SSynFightActivitySchedule = class("SSynFightActivitySchedule")
SSynFightActivitySchedule.TYPEID = 12614153
function SSynFightActivitySchedule:ctor(activity_cfg_id, complete_sortids, daily_get_team_member_award_times)
  self.id = 12614153
  self.activity_cfg_id = activity_cfg_id or nil
  self.complete_sortids = complete_sortids or {}
  self.daily_get_team_member_award_times = daily_get_team_member_award_times or nil
end
function SSynFightActivitySchedule:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalCompactUInt32(table.getn(self.complete_sortids))
  for _, v in ipairs(self.complete_sortids) do
    os:marshalInt32(v)
  end
  os:marshalInt32(self.daily_get_team_member_award_times)
end
function SSynFightActivitySchedule:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.complete_sortids, v)
  end
  self.daily_get_team_member_award_times = os:unmarshalInt32()
end
function SSynFightActivitySchedule:sizepolicy(size)
  return size <= 65535
end
return SSynFightActivitySchedule
