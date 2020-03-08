local SSynCrossFieldSeasonInfo = class("SSynCrossFieldSeasonInfo")
SSynCrossFieldSeasonInfo.TYPEID = 12619537
function SSynCrossFieldSeasonInfo:ctor(season, star_num, win_point, straight_win_num, star_num_timestamp, current_week_point, last_get_point_time)
  self.id = 12619537
  self.season = season or nil
  self.star_num = star_num or nil
  self.win_point = win_point or nil
  self.straight_win_num = straight_win_num or nil
  self.star_num_timestamp = star_num_timestamp or nil
  self.current_week_point = current_week_point or nil
  self.last_get_point_time = last_get_point_time or nil
end
function SSynCrossFieldSeasonInfo:marshal(os)
  os:marshalInt32(self.season)
  os:marshalInt32(self.star_num)
  os:marshalInt32(self.win_point)
  os:marshalInt32(self.straight_win_num)
  os:marshalInt32(self.star_num_timestamp)
  os:marshalInt32(self.current_week_point)
  os:marshalInt64(self.last_get_point_time)
end
function SSynCrossFieldSeasonInfo:unmarshal(os)
  self.season = os:unmarshalInt32()
  self.star_num = os:unmarshalInt32()
  self.win_point = os:unmarshalInt32()
  self.straight_win_num = os:unmarshalInt32()
  self.star_num_timestamp = os:unmarshalInt32()
  self.current_week_point = os:unmarshalInt32()
  self.last_get_point_time = os:unmarshalInt64()
end
function SSynCrossFieldSeasonInfo:sizepolicy(size)
  return size <= 65535
end
return SSynCrossFieldSeasonInfo
