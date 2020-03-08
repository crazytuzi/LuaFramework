local CStartBuildingLevelUpReq = class("CStartBuildingLevelUpReq")
CStartBuildingLevelUpReq.TYPEID = 12589905
function CStartBuildingLevelUpReq:ctor(buildingType, roleId)
  self.id = 12589905
  self.buildingType = buildingType or nil
  self.roleId = roleId or nil
end
function CStartBuildingLevelUpReq:marshal(os)
  os:marshalInt32(self.buildingType)
  os:marshalInt64(self.roleId)
end
function CStartBuildingLevelUpReq:unmarshal(os)
  self.buildingType = os:unmarshalInt32()
  self.roleId = os:unmarshalInt64()
end
function CStartBuildingLevelUpReq:sizepolicy(size)
  return size <= 65535
end
return CStartBuildingLevelUpReq
