local SStopMusicGame = class("SStopMusicGame")
SStopMusicGame.TYPEID = 12609794
SStopMusicGame.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SStopMusicGame.ROLE_STATUS_ERROR = -2
SStopMusicGame.PARAM_ERROR = -3
SStopMusicGame.GAME_IS_NOT_START = -4
SStopMusicGame.AWARD_FAIL = -5
SStopMusicGame.RIGHT_SUN_AWARD_FAIL = -6
SStopMusicGame.POINT_TO_UPPER_LINIT = -7
SStopMusicGame.GAME_OVER = 1
SStopMusicGame.GAME_PAUSE = 2
function SStopMusicGame:ctor(game_id, res)
  self.id = 12609794
  self.game_id = game_id or nil
  self.res = res or nil
end
function SStopMusicGame:marshal(os)
  os:marshalInt32(self.game_id)
  os:marshalInt32(self.res)
end
function SStopMusicGame:unmarshal(os)
  self.game_id = os:unmarshalInt32()
  self.res = os:unmarshalInt32()
end
function SStopMusicGame:sizepolicy(size)
  return size <= 65535
end
return SStopMusicGame
