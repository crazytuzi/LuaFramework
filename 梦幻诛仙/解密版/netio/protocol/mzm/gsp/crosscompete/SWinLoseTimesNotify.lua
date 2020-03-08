local SWinLoseTimesNotify = class("SWinLoseTimesNotify")
SWinLoseTimesNotify.TYPEID = 12616744
function SWinLoseTimesNotify:ctor(win_times, lose_times, win_streak, escape_times)
  self.id = 12616744
  self.win_times = win_times or nil
  self.lose_times = lose_times or nil
  self.win_streak = win_streak or nil
  self.escape_times = escape_times or nil
end
function SWinLoseTimesNotify:marshal(os)
  os:marshalInt32(self.win_times)
  os:marshalInt32(self.lose_times)
  os:marshalInt32(self.win_streak)
  os:marshalInt32(self.escape_times)
end
function SWinLoseTimesNotify:unmarshal(os)
  self.win_times = os:unmarshalInt32()
  self.lose_times = os:unmarshalInt32()
  self.win_streak = os:unmarshalInt32()
  self.escape_times = os:unmarshalInt32()
end
function SWinLoseTimesNotify:sizepolicy(size)
  return size <= 65535
end
return SWinLoseTimesNotify
