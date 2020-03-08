local SMaidRoomLevelUpRes = class("SMaidRoomLevelUpRes")
SMaidRoomLevelUpRes.TYPEID = 12605441
function SMaidRoomLevelUpRes:ctor(maidRoomLevel)
  self.id = 12605441
  self.maidRoomLevel = maidRoomLevel or nil
end
function SMaidRoomLevelUpRes:marshal(os)
  os:marshalInt32(self.maidRoomLevel)
end
function SMaidRoomLevelUpRes:unmarshal(os)
  self.maidRoomLevel = os:unmarshalInt32()
end
function SMaidRoomLevelUpRes:sizepolicy(size)
  return size <= 65535
end
return SMaidRoomLevelUpRes
