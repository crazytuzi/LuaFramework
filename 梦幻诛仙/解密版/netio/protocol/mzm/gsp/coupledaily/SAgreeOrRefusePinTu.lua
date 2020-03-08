local SAgreeOrRefusePinTu = class("SAgreeOrRefusePinTu")
SAgreeOrRefusePinTu.TYPEID = 12602374
function SAgreeOrRefusePinTu:ctor(operator, memberRoleId, memberRoleName)
  self.id = 12602374
  self.operator = operator or nil
  self.memberRoleId = memberRoleId or nil
  self.memberRoleName = memberRoleName or nil
end
function SAgreeOrRefusePinTu:marshal(os)
  os:marshalInt32(self.operator)
  os:marshalInt64(self.memberRoleId)
  os:marshalString(self.memberRoleName)
end
function SAgreeOrRefusePinTu:unmarshal(os)
  self.operator = os:unmarshalInt32()
  self.memberRoleId = os:unmarshalInt64()
  self.memberRoleName = os:unmarshalString()
end
function SAgreeOrRefusePinTu:sizepolicy(size)
  return size <= 65535
end
return SAgreeOrRefusePinTu
