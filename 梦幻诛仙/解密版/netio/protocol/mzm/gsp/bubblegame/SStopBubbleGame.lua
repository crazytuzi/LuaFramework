local SStopBubbleGame = class("SStopBubbleGame")
SStopBubbleGame.TYPEID = 12610049
SStopBubbleGame.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SStopBubbleGame.ROLE_STATUS_ERROR = -2
SStopBubbleGame.PARAM_ERROR = -3
SStopBubbleGame.GAME_IS_NOT_START = -4
SStopBubbleGame.AWARD_FAIL = -5
SStopBubbleGame.RIGHT_SUN_AWARD_FAIL = -6
SStopBubbleGame.POINT_TO_UPPER_LINIT = -7
SStopBubbleGame.GAME_OVER = 1
function SStopBubbleGame:ctor(game_id, res)
  self.id = 12610049
  self.game_id = game_id or nil
  self.res = res or nil
end
function SStopBubbleGame:marshal(os)
  os:marshalInt32(self.game_id)
  os:marshalInt32(self.res)
end
function SStopBubbleGame:unmarshal(os)
  self.game_id = os:unmarshalInt32()
  self.res = os:unmarshalInt32()
end
function SStopBubbleGame:sizepolicy(size)
  return size <= 65535
end
return SStopBubbleGame
