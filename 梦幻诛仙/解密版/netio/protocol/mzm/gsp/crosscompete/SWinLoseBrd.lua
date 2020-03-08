local SWinLoseBrd = class("SWinLoseBrd")
SWinLoseBrd.TYPEID = 12616728
SWinLoseBrd.RESULT__GIVE_UP = 1
SWinLoseBrd.RESULT__EARLY = 2
SWinLoseBrd.RESULT__TIMEOUT = 3
function SWinLoseBrd:ctor(winner_id, winner_name, winner_score, winner_participate_count, winner_left_count, winner_win_times, loser_id, loser_name, loser_score, loser_participate_count, loser_left_count, loser_win_times, result)
  self.id = 12616728
  self.winner_id = winner_id or nil
  self.winner_name = winner_name or nil
  self.winner_score = winner_score or nil
  self.winner_participate_count = winner_participate_count or nil
  self.winner_left_count = winner_left_count or nil
  self.winner_win_times = winner_win_times or nil
  self.loser_id = loser_id or nil
  self.loser_name = loser_name or nil
  self.loser_score = loser_score or nil
  self.loser_participate_count = loser_participate_count or nil
  self.loser_left_count = loser_left_count or nil
  self.loser_win_times = loser_win_times or nil
  self.result = result or nil
end
function SWinLoseBrd:marshal(os)
  os:marshalInt64(self.winner_id)
  os:marshalString(self.winner_name)
  os:marshalInt32(self.winner_score)
  os:marshalInt32(self.winner_participate_count)
  os:marshalInt32(self.winner_left_count)
  os:marshalInt32(self.winner_win_times)
  os:marshalInt64(self.loser_id)
  os:marshalString(self.loser_name)
  os:marshalInt32(self.loser_score)
  os:marshalInt32(self.loser_participate_count)
  os:marshalInt32(self.loser_left_count)
  os:marshalInt32(self.loser_win_times)
  os:marshalInt32(self.result)
end
function SWinLoseBrd:unmarshal(os)
  self.winner_id = os:unmarshalInt64()
  self.winner_name = os:unmarshalString()
  self.winner_score = os:unmarshalInt32()
  self.winner_participate_count = os:unmarshalInt32()
  self.winner_left_count = os:unmarshalInt32()
  self.winner_win_times = os:unmarshalInt32()
  self.loser_id = os:unmarshalInt64()
  self.loser_name = os:unmarshalString()
  self.loser_score = os:unmarshalInt32()
  self.loser_participate_count = os:unmarshalInt32()
  self.loser_left_count = os:unmarshalInt32()
  self.loser_win_times = os:unmarshalInt32()
  self.result = os:unmarshalInt32()
end
function SWinLoseBrd:sizepolicy(size)
  return size <= 65535
end
return SWinLoseBrd
