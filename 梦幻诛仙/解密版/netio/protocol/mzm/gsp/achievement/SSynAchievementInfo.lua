local SSynAchievementInfo = class("SSynAchievementInfo")
SSynAchievementInfo.TYPEID = 12603907
function SSynAchievementInfo:ctor(activity_cfg_id, goal_map_info, aleardy_awarded_score, now_score_value)
  self.id = 12603907
  self.activity_cfg_id = activity_cfg_id or nil
  self.goal_map_info = goal_map_info or {}
  self.aleardy_awarded_score = aleardy_awarded_score or {}
  self.now_score_value = now_score_value or nil
end
function SSynAchievementInfo:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  do
    local _size_ = 0
    for _, _ in pairs(self.goal_map_info) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.goal_map_info) do
      os:marshalInt32(k)
      v:marshal(os)
    end
  end
  do
    local _size_ = 0
    for _, _ in pairs(self.aleardy_awarded_score) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, _ in pairs(self.aleardy_awarded_score) do
      os:marshalInt32(k)
    end
  end
  os:marshalInt32(self.now_score_value)
end
function SSynAchievementInfo:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.achievement.AchievementGoalInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.goal_map_info[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    self.aleardy_awarded_score[v] = v
  end
  self.now_score_value = os:unmarshalInt32()
end
function SSynAchievementInfo:sizepolicy(size)
  return size <= 65535
end
return SSynAchievementInfo
