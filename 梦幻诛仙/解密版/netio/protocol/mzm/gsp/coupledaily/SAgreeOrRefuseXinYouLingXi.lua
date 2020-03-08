local SAgreeOrRefuseXinYouLingXi = class("SAgreeOrRefuseXinYouLingXi")
SAgreeOrRefuseXinYouLingXi.TYPEID = 12602382
function SAgreeOrRefuseXinYouLingXi:ctor(operator, memberRoleId, memberRoleName)
  self.id = 12602382
  self.operator = operator or nil
  self.memberRoleId = memberRoleId or nil
  self.memberRoleName = memberRoleName or nil
end
function SAgreeOrRefuseXinYouLingXi:marshal(os)
  os:marshalInt32(self.operator)
  os:marshalInt64(self.memberRoleId)
  os:marshalString(self.memberRoleName)
end
function SAgreeOrRefuseXinYouLingXi:unmarshal(os)
  self.operator = os:unmarshalInt32()
  self.memberRoleId = os:unmarshalInt64()
  self.memberRoleName = os:unmarshalString()
end
function SAgreeOrRefuseXinYouLingXi:sizepolicy(size)
  return size <= 65535
end
return SAgreeOrRefuseXinYouLingXi
