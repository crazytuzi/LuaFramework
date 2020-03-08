local SSyncBuildingStartLevelUp = class("SSyncBuildingStartLevelUp")
SSyncBuildingStartLevelUp.TYPEID = 12589908
function SSyncBuildingStartLevelUp:ctor(buildingType, endTime, roleId, gangMoney)
  self.id = 12589908
  self.buildingType = buildingType or nil
  self.endTime = endTime or nil
  self.roleId = roleId or nil
  self.gangMoney = gangMoney or nil
end
function SSyncBuildingStartLevelUp:marshal(os)
  os:marshalInt32(self.buildingType)
  os:marshalInt32(self.endTime)
  os:marshalInt64(self.roleId)
  os:marshalInt32(self.gangMoney)
end
function SSyncBuildingStartLevelUp:unmarshal(os)
  self.buildingType = os:unmarshalInt32()
  self.endTime = os:unmarshalInt32()
  self.roleId = os:unmarshalInt64()
  self.gangMoney = os:unmarshalInt32()
end
function SSyncBuildingStartLevelUp:sizepolicy(size)
  return size <= 65535
end
return SSyncBuildingStartLevelUp
