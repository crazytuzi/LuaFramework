local SDrugRoomLevelUpRes = class("SDrugRoomLevelUpRes")
SDrugRoomLevelUpRes.TYPEID = 12605466
function SDrugRoomLevelUpRes:ctor(drugRoomLevel)
  self.id = 12605466
  self.drugRoomLevel = drugRoomLevel or nil
end
function SDrugRoomLevelUpRes:marshal(os)
  os:marshalInt32(self.drugRoomLevel)
end
function SDrugRoomLevelUpRes:unmarshal(os)
  self.drugRoomLevel = os:unmarshalInt32()
end
function SDrugRoomLevelUpRes:sizepolicy(size)
  return size <= 65535
end
return SDrugRoomLevelUpRes
