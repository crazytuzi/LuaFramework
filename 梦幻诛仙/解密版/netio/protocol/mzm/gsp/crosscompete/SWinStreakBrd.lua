local SWinStreakBrd = class("SWinStreakBrd")
SWinStreakBrd.TYPEID = 12616723
function SWinStreakBrd:ctor(roleid, name, win_streak)
  self.id = 12616723
  self.roleid = roleid or nil
  self.name = name or nil
  self.win_streak = win_streak or nil
end
function SWinStreakBrd:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalString(self.name)
  os:marshalInt32(self.win_streak)
end
function SWinStreakBrd:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.name = os:unmarshalString()
  self.win_streak = os:unmarshalInt32()
end
function SWinStreakBrd:sizepolicy(size)
  return size <= 65535
end
return SWinStreakBrd
