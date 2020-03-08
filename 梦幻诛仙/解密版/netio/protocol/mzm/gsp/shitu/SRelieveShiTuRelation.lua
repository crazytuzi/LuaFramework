local SRelieveShiTuRelation = class("SRelieveShiTuRelation")
SRelieveShiTuRelation.TYPEID = 12601615
function SRelieveShiTuRelation:ctor(apprenticeRoleId, apprenticeRoleName, masterRoleId, masterRoleName)
  self.id = 12601615
  self.apprenticeRoleId = apprenticeRoleId or nil
  self.apprenticeRoleName = apprenticeRoleName or nil
  self.masterRoleId = masterRoleId or nil
  self.masterRoleName = masterRoleName or nil
end
function SRelieveShiTuRelation:marshal(os)
  os:marshalInt64(self.apprenticeRoleId)
  os:marshalString(self.apprenticeRoleName)
  os:marshalInt64(self.masterRoleId)
  os:marshalString(self.masterRoleName)
end
function SRelieveShiTuRelation:unmarshal(os)
  self.apprenticeRoleId = os:unmarshalInt64()
  self.apprenticeRoleName = os:unmarshalString()
  self.masterRoleId = os:unmarshalInt64()
  self.masterRoleName = os:unmarshalString()
end
function SRelieveShiTuRelation:sizepolicy(size)
  return size <= 65535
end
return SRelieveShiTuRelation
