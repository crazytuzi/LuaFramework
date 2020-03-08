local SSynRefuseOrAgreeTeamInstanceRes = class("SSynRefuseOrAgreeTeamInstanceRes")
SSynRefuseOrAgreeTeamInstanceRes.TYPEID = 794891
function SSynRefuseOrAgreeTeamInstanceRes:ctor(roleid, roleName, operation)
  self.id = 794891
  self.roleid = roleid or nil
  self.roleName = roleName or nil
  self.operation = operation or nil
end
function SSynRefuseOrAgreeTeamInstanceRes:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalString(self.roleName)
  os:marshalInt32(self.operation)
end
function SSynRefuseOrAgreeTeamInstanceRes:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.roleName = os:unmarshalString()
  self.operation = os:unmarshalInt32()
end
function SSynRefuseOrAgreeTeamInstanceRes:sizepolicy(size)
  return size <= 65535
end
return SSynRefuseOrAgreeTeamInstanceRes
