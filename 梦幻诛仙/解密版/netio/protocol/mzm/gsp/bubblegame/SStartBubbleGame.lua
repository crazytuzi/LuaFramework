local SStartBubbleGame = class("SStartBubbleGame")
SStartBubbleGame.TYPEID = 12610050
SStartBubbleGame.RESTART_GAME = 0
SStartBubbleGame.RESUME_GAME = 1
function SStartBubbleGame:ctor(game_id, complete_turn_index, current_point, start_timestamp, is_resume_game)
  self.id = 12610050
  self.game_id = game_id or nil
  self.complete_turn_index = complete_turn_index or nil
  self.current_point = current_point or nil
  self.start_timestamp = start_timestamp or nil
  self.is_resume_game = is_resume_game or nil
end
function SStartBubbleGame:marshal(os)
  os:marshalInt32(self.game_id)
  os:marshalInt32(self.complete_turn_index)
  os:marshalInt32(self.current_point)
  os:marshalInt32(self.start_timestamp)
  os:marshalInt32(self.is_resume_game)
end
function SStartBubbleGame:unmarshal(os)
  self.game_id = os:unmarshalInt32()
  self.complete_turn_index = os:unmarshalInt32()
  self.current_point = os:unmarshalInt32()
  self.start_timestamp = os:unmarshalInt32()
  self.is_resume_game = os:unmarshalInt32()
end
function SStartBubbleGame:sizepolicy(size)
  return size <= 65535
end
return SStartBubbleGame
