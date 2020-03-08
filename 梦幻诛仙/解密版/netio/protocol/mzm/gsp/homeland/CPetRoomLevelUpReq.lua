local CPetRoomLevelUpReq = class("CPetRoomLevelUpReq")
CPetRoomLevelUpReq.TYPEID = 12605455
function CPetRoomLevelUpReq:ctor()
  self.id = 12605455
end
function CPetRoomLevelUpReq:marshal(os)
end
function CPetRoomLevelUpReq:unmarshal(os)
end
function CPetRoomLevelUpReq:sizepolicy(size)
  return size <= 65535
end
return CPetRoomLevelUpReq
