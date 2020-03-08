local SAchievementFinishBrd = class("SAchievementFinishBrd")
SAchievementFinishBrd.TYPEID = 12603911
function SAchievementFinishBrd:ctor(role_name, goal_cfg_id, faction_id)
  self.id = 12603911
  self.role_name = role_name or nil
  self.goal_cfg_id = goal_cfg_id or nil
  self.faction_id = faction_id or nil
end
function SAchievementFinishBrd:marshal(os)
  os:marshalString(self.role_name)
  os:marshalInt32(self.goal_cfg_id)
  os:marshalInt64(self.faction_id)
end
function SAchievementFinishBrd:unmarshal(os)
  self.role_name = os:unmarshalString()
  self.goal_cfg_id = os:unmarshalInt32()
  self.faction_id = os:unmarshalInt64()
end
function SAchievementFinishBrd:sizepolicy(size)
  return size <= 65535
end
return SAchievementFinishBrd
