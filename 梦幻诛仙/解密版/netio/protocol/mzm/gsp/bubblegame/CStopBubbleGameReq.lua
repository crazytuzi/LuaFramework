local CStopBubbleGameReq = class("CStopBubbleGameReq")
CStopBubbleGameReq.TYPEID = 12610051
function CStopBubbleGameReq:ctor(game_id)
  self.id = 12610051
  self.game_id = game_id or nil
end
function CStopBubbleGameReq:marshal(os)
  os:marshalInt32(self.game_id)
end
function CStopBubbleGameReq:unmarshal(os)
  self.game_id = os:unmarshalInt32()
end
function CStopBubbleGameReq:sizepolicy(size)
  return size <= 65535
end
return CStopBubbleGameReq
