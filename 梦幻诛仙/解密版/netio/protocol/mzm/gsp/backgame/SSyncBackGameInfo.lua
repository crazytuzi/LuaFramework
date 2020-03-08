local SSyncBackGameInfo = class("SSyncBackGameInfo")
SSyncBackGameInfo.TYPEID = 12604421
function SSyncBackGameInfo:ctor(current_score_value, current_award_score_index_id, award_day, award_back_game_level, left_time)
  self.id = 12604421
  self.current_score_value = current_score_value or nil
  self.current_award_score_index_id = current_award_score_index_id or nil
  self.award_day = award_day or nil
  self.award_back_game_level = award_back_game_level or nil
  self.left_time = left_time or nil
end
function SSyncBackGameInfo:marshal(os)
  os:marshalInt32(self.current_score_value)
  os:marshalInt32(self.current_award_score_index_id)
  os:marshalInt32(self.award_day)
  os:marshalInt32(self.award_back_game_level)
  os:marshalInt64(self.left_time)
end
function SSyncBackGameInfo:unmarshal(os)
  self.current_score_value = os:unmarshalInt32()
  self.current_award_score_index_id = os:unmarshalInt32()
  self.award_day = os:unmarshalInt32()
  self.award_back_game_level = os:unmarshalInt32()
  self.left_time = os:unmarshalInt64()
end
function SSyncBackGameInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncBackGameInfo
