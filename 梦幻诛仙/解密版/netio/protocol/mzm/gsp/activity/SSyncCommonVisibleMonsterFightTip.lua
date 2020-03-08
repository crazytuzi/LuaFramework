local SSyncCommonVisibleMonsterFightTip = class("SSyncCommonVisibleMonsterFightTip")
SSyncCommonVisibleMonsterFightTip.TYPEID = 12587609
function SSyncCommonVisibleMonsterFightTip:ctor(activity_cfg_id, monster_category_id, today_kill_times, today_max_kill_times)
  self.id = 12587609
  self.activity_cfg_id = activity_cfg_id or nil
  self.monster_category_id = monster_category_id or nil
  self.today_kill_times = today_kill_times or nil
  self.today_max_kill_times = today_max_kill_times or nil
end
function SSyncCommonVisibleMonsterFightTip:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.monster_category_id)
  os:marshalInt32(self.today_kill_times)
  os:marshalInt32(self.today_max_kill_times)
end
function SSyncCommonVisibleMonsterFightTip:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.monster_category_id = os:unmarshalInt32()
  self.today_kill_times = os:unmarshalInt32()
  self.today_max_kill_times = os:unmarshalInt32()
end
function SSyncCommonVisibleMonsterFightTip:sizepolicy(size)
  return size <= 65535
end
return SSyncCommonVisibleMonsterFightTip
