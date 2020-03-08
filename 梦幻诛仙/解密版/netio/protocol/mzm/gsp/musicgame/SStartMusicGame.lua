local SStartMusicGame = class("SStartMusicGame")
SStartMusicGame.TYPEID = 12609796
function SStartMusicGame:ctor(game_id, complete_turn_index, current_point)
  self.id = 12609796
  self.game_id = game_id or nil
  self.complete_turn_index = complete_turn_index or nil
  self.current_point = current_point or nil
end
function SStartMusicGame:marshal(os)
  os:marshalInt32(self.game_id)
  os:marshalInt32(self.complete_turn_index)
  os:marshalInt32(self.current_point)
end
function SStartMusicGame:unmarshal(os)
  self.game_id = os:unmarshalInt32()
  self.complete_turn_index = os:unmarshalInt32()
  self.current_point = os:unmarshalInt32()
end
function SStartMusicGame:sizepolicy(size)
  return size <= 65535
end
return SStartMusicGame
