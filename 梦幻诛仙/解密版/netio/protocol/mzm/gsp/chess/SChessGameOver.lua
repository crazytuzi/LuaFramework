local SChessGameOver = class("SChessGameOver")
SChessGameOver.TYPEID = 12619021
SChessGameOver.WIN = 1
SChessGameOver.LOSE = 2
SChessGameOver.DRAW = 3
SChessGameOver.WIPE_OUT_ALL = 1
SChessGameOver.SURRENDER = 2
SChessGameOver.TIME_UP_DRAW = 3
SChessGameOver.QUANTITY_COMPARE = 4
SChessGameOver.NO_OPERATE_LOSE = 5
function SChessGameOver:ctor(result, reason)
  self.id = 12619021
  self.result = result or nil
  self.reason = reason or nil
end
function SChessGameOver:marshal(os)
  os:marshalInt32(self.result)
  os:marshalInt32(self.reason)
end
function SChessGameOver:unmarshal(os)
  self.result = os:unmarshalInt32()
  self.reason = os:unmarshalInt32()
end
function SChessGameOver:sizepolicy(size)
  return size <= 65535
end
return SChessGameOver
