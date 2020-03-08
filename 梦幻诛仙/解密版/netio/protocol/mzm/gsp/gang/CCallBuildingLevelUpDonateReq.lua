local CCallBuildingLevelUpDonateReq = class("CCallBuildingLevelUpDonateReq")
CCallBuildingLevelUpDonateReq.TYPEID = 12589909
function CCallBuildingLevelUpDonateReq:ctor(buildingType)
  self.id = 12589909
  self.buildingType = buildingType or nil
end
function CCallBuildingLevelUpDonateReq:marshal(os)
  os:marshalInt32(self.buildingType)
end
function CCallBuildingLevelUpDonateReq:unmarshal(os)
  self.buildingType = os:unmarshalInt32()
end
function CCallBuildingLevelUpDonateReq:sizepolicy(size)
  return size <= 65535
end
return CCallBuildingLevelUpDonateReq
