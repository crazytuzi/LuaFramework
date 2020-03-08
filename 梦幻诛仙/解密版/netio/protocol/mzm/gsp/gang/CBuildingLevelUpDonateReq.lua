local CBuildingLevelUpDonateReq = class("CBuildingLevelUpDonateReq")
CBuildingLevelUpDonateReq.TYPEID = 12589910
function CBuildingLevelUpDonateReq:ctor(buildingType, donateLv)
  self.id = 12589910
  self.buildingType = buildingType or nil
  self.donateLv = donateLv or nil
end
function CBuildingLevelUpDonateReq:marshal(os)
  os:marshalInt32(self.buildingType)
  os:marshalInt32(self.donateLv)
end
function CBuildingLevelUpDonateReq:unmarshal(os)
  self.buildingType = os:unmarshalInt32()
  self.donateLv = os:unmarshalInt32()
end
function CBuildingLevelUpDonateReq:sizepolicy(size)
  return size <= 65535
end
return CBuildingLevelUpDonateReq
