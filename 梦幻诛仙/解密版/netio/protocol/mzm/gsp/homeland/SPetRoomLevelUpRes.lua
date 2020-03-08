local SPetRoomLevelUpRes = class("SPetRoomLevelUpRes")
SPetRoomLevelUpRes.TYPEID = 12605479
function SPetRoomLevelUpRes:ctor(petRoomLevel)
  self.id = 12605479
  self.petRoomLevel = petRoomLevel or nil
end
function SPetRoomLevelUpRes:marshal(os)
  os:marshalInt32(self.petRoomLevel)
end
function SPetRoomLevelUpRes:unmarshal(os)
  self.petRoomLevel = os:unmarshalInt32()
end
function SPetRoomLevelUpRes:sizepolicy(size)
  return size <= 65535
end
return SPetRoomLevelUpRes
