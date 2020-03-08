local SSyncBuildingLevelUpSuccess = class("SSyncBuildingLevelUpSuccess")
SSyncBuildingLevelUpSuccess.TYPEID = 12589907
function SSyncBuildingLevelUpSuccess:ctor(buildingType, level)
  self.id = 12589907
  self.buildingType = buildingType or nil
  self.level = level or nil
end
function SSyncBuildingLevelUpSuccess:marshal(os)
  os:marshalInt32(self.buildingType)
  os:marshalInt32(self.level)
end
function SSyncBuildingLevelUpSuccess:unmarshal(os)
  self.buildingType = os:unmarshalInt32()
  self.level = os:unmarshalInt32()
end
function SSyncBuildingLevelUpSuccess:sizepolicy(size)
  return size <= 65535
end
return SSyncBuildingLevelUpSuccess
