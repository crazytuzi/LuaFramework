local SSynCrossFieldResultInfo = class("SSynCrossFieldResultInfo")
SSynCrossFieldResultInfo.TYPEID = 12619527
function SSynCrossFieldResultInfo:ctor(season, is_active_leave, result, is_mvp, original_point, current_point, current_week_point, last_get_point_time, original_star_num, current_star_num, original_win_point, current_win_point, original_straight_win_num, current_straight_win_num, star_num_timestamp)
  self.id = 12619527
  self.season = season or nil
  self.is_active_leave = is_active_leave or nil
  self.result = result or nil
  self.is_mvp = is_mvp or nil
  self.original_point = original_point or nil
  self.current_point = current_point or nil
  self.current_week_point = current_week_point or nil
  self.last_get_point_time = last_get_point_time or nil
  self.original_star_num = original_star_num or nil
  self.current_star_num = current_star_num or nil
  self.original_win_point = original_win_point or nil
  self.current_win_point = current_win_point or nil
  self.original_straight_win_num = original_straight_win_num or nil
  self.current_straight_win_num = current_straight_win_num or nil
  self.star_num_timestamp = star_num_timestamp or nil
end
function SSynCrossFieldResultInfo:marshal(os)
  os:marshalInt32(self.season)
  os:marshalUInt8(self.is_active_leave)
  os:marshalUInt8(self.result)
  os:marshalUInt8(self.is_mvp)
  os:marshalInt64(self.original_point)
  os:marshalInt64(self.current_point)
  os:marshalInt32(self.current_week_point)
  os:marshalInt64(self.last_get_point_time)
  os:marshalInt32(self.original_star_num)
  os:marshalInt32(self.current_star_num)
  os:marshalInt32(self.original_win_point)
  os:marshalInt32(self.current_win_point)
  os:marshalInt32(self.original_straight_win_num)
  os:marshalInt32(self.current_straight_win_num)
  os:marshalInt32(self.star_num_timestamp)
end
function SSynCrossFieldResultInfo:unmarshal(os)
  self.season = os:unmarshalInt32()
  self.is_active_leave = os:unmarshalUInt8()
  self.result = os:unmarshalUInt8()
  self.is_mvp = os:unmarshalUInt8()
  self.original_point = os:unmarshalInt64()
  self.current_point = os:unmarshalInt64()
  self.current_week_point = os:unmarshalInt32()
  self.last_get_point_time = os:unmarshalInt64()
  self.original_star_num = os:unmarshalInt32()
  self.current_star_num = os:unmarshalInt32()
  self.original_win_point = os:unmarshalInt32()
  self.current_win_point = os:unmarshalInt32()
  self.original_straight_win_num = os:unmarshalInt32()
  self.current_straight_win_num = os:unmarshalInt32()
  self.star_num_timestamp = os:unmarshalInt32()
end
function SSynCrossFieldResultInfo:sizepolicy(size)
  return size <= 65535
end
return SSynCrossFieldResultInfo
