local SSyncCallBuildingLevelUpDonate = class("SSyncCallBuildingLevelUpDonate")
SSyncCallBuildingLevelUpDonate.TYPEID = 12589904
function SSyncCallBuildingLevelUpDonate:ctor(buildingType)
  self.id = 12589904
  self.buildingType = buildingType or nil
end
function SSyncCallBuildingLevelUpDonate:marshal(os)
  os:marshalInt32(self.buildingType)
end
function SSyncCallBuildingLevelUpDonate:unmarshal(os)
  self.buildingType = os:unmarshalInt32()
end
function SSyncCallBuildingLevelUpDonate:sizepolicy(size)
  return size <= 65535
end
return SSyncCallBuildingLevelUpDonate
