local CMaidRoomLevelUpReq = class("CMaidRoomLevelUpReq")
CMaidRoomLevelUpReq.TYPEID = 12605460
function CMaidRoomLevelUpReq:ctor()
  self.id = 12605460
end
function CMaidRoomLevelUpReq:marshal(os)
end
function CMaidRoomLevelUpReq:unmarshal(os)
end
function CMaidRoomLevelUpReq:sizepolicy(size)
  return size <= 65535
end
return CMaidRoomLevelUpReq
