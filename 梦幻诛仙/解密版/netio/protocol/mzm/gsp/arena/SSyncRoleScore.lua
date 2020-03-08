local SSyncRoleScore = class("SSyncRoleScore")
SSyncRoleScore.TYPEID = 12596741
function SSyncRoleScore:ctor(camp, score, action_point, win_times)
  self.id = 12596741
  self.camp = camp or nil
  self.score = score or nil
  self.action_point = action_point or nil
  self.win_times = win_times or nil
end
function SSyncRoleScore:marshal(os)
  os:marshalInt32(self.camp)
  os:marshalInt32(self.score)
  os:marshalInt32(self.action_point)
  os:marshalInt32(self.win_times)
end
function SSyncRoleScore:unmarshal(os)
  self.camp = os:unmarshalInt32()
  self.score = os:unmarshalInt32()
  self.action_point = os:unmarshalInt32()
  self.win_times = os:unmarshalInt32()
end
function SSyncRoleScore:sizepolicy(size)
  return size <= 65535
end
return SSyncRoleScore
