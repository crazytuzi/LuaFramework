local SReportRoleRes = class("SReportRoleRes")
SReportRoleRes.TYPEID = 12585246
SReportRoleRes.SUCCESS = 0
SReportRoleRes.ERROR_TARGET_ROLE_NOT_EXIST = 1
SReportRoleRes.ERROR_ROLE_LEVEL_INVALID = 2
SReportRoleRes.ERROR_ROLE_VIGOR_NOT_ENOUGH = 3
SReportRoleRes.ERROR_UNKNOW = 4
SReportRoleRes.ERROR_REPORTED_ROLE = 5
SReportRoleRes.ERROR_BASIS_EMPTY = 6
function SReportRoleRes:ctor(resultcode, targetRoleId, targetRoleName)
  self.id = 12585246
  self.resultcode = resultcode or nil
  self.targetRoleId = targetRoleId or nil
  self.targetRoleName = targetRoleName or nil
end
function SReportRoleRes:marshal(os)
  os:marshalInt32(self.resultcode)
  os:marshalInt64(self.targetRoleId)
  os:marshalString(self.targetRoleName)
end
function SReportRoleRes:unmarshal(os)
  self.resultcode = os:unmarshalInt32()
  self.targetRoleId = os:unmarshalInt64()
  self.targetRoleName = os:unmarshalString()
end
function SReportRoleRes:sizepolicy(size)
  return size <= 65535
end
return SReportRoleRes
