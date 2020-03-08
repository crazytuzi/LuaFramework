local SBedRoomLevelUpRes = class("SBedRoomLevelUpRes")
SBedRoomLevelUpRes.TYPEID = 12605449
function SBedRoomLevelUpRes:ctor(bedRoomLevel)
  self.id = 12605449
  self.bedRoomLevel = bedRoomLevel or nil
end
function SBedRoomLevelUpRes:marshal(os)
  os:marshalInt32(self.bedRoomLevel)
end
function SBedRoomLevelUpRes:unmarshal(os)
  self.bedRoomLevel = os:unmarshalInt32()
end
function SBedRoomLevelUpRes:sizepolicy(size)
  return size <= 65535
end
return SBedRoomLevelUpRes
