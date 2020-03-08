local CPauseMusicGameReq = class("CPauseMusicGameReq")
CPauseMusicGameReq.TYPEID = 12609797
function CPauseMusicGameReq:ctor(game_id)
  self.id = 12609797
  self.game_id = game_id or nil
end
function CPauseMusicGameReq:marshal(os)
  os:marshalInt32(self.game_id)
end
function CPauseMusicGameReq:unmarshal(os)
  self.game_id = os:unmarshalInt32()
end
function CPauseMusicGameReq:sizepolicy(size)
  return size <= 65535
end
return CPauseMusicGameReq
