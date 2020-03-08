local SSyncScore = class("SSyncScore")
SSyncScore.TYPEID = 12596225
function SSyncScore:ctor(score, win_times, lose_times)
  self.id = 12596225
  self.score = score or nil
  self.win_times = win_times or nil
  self.lose_times = lose_times or nil
end
function SSyncScore:marshal(os)
  os:marshalInt32(self.score)
  os:marshalInt32(self.win_times)
  os:marshalInt32(self.lose_times)
end
function SSyncScore:unmarshal(os)
  self.score = os:unmarshalInt32()
  self.win_times = os:unmarshalInt32()
  self.lose_times = os:unmarshalInt32()
end
function SSyncScore:sizepolicy(size)
  return size <= 65535
end
return SSyncScore
