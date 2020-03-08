local SSyncRoleWorldGoalInfo = class("SSyncRoleWorldGoalInfo")
SSyncRoleWorldGoalInfo.TYPEID = 12594439
function SSyncRoleWorldGoalInfo:ctor(role_world_goal_info)
  self.id = 12594439
  self.role_world_goal_info = role_world_goal_info or {}
end
function SSyncRoleWorldGoalInfo:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.role_world_goal_info) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.role_world_goal_info) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SSyncRoleWorldGoalInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.role_world_goal_info[k] = v
  end
end
function SSyncRoleWorldGoalInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncRoleWorldGoalInfo
