local SSyncBuildingLevelUpDonate = class("SSyncBuildingLevelUpDonate")
SSyncBuildingLevelUpDonate.TYPEID = 12589906
function SSyncBuildingLevelUpDonate:ctor(buildingType, roleId, donateLv, endTime)
  self.id = 12589906
  self.buildingType = buildingType or nil
  self.roleId = roleId or nil
  self.donateLv = donateLv or nil
  self.endTime = endTime or nil
end
function SSyncBuildingLevelUpDonate:marshal(os)
  os:marshalInt32(self.buildingType)
  os:marshalInt64(self.roleId)
  os:marshalInt32(self.donateLv)
  os:marshalInt32(self.endTime)
end
function SSyncBuildingLevelUpDonate:unmarshal(os)
  self.buildingType = os:unmarshalInt32()
  self.roleId = os:unmarshalInt64()
  self.donateLv = os:unmarshalInt32()
  self.endTime = os:unmarshalInt32()
end
function SSyncBuildingLevelUpDonate:sizepolicy(size)
  return size <= 65535
end
return SSyncBuildingLevelUpDonate
