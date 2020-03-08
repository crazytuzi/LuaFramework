local CBedRoomLevelUpReq = class("CBedRoomLevelUpReq")
CBedRoomLevelUpReq.TYPEID = 12605490
function CBedRoomLevelUpReq:ctor()
  self.id = 12605490
end
function CBedRoomLevelUpReq:marshal(os)
end
function CBedRoomLevelUpReq:unmarshal(os)
end
function CBedRoomLevelUpReq:sizepolicy(size)
  return size <= 65535
end
return CBedRoomLevelUpReq
